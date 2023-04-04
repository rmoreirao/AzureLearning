// Inspiration from https://github.com/Azure-Samples/container-apps-store-api-microservice
/*
1) Command Line to execute bicep file: 
az group create --name rg-tododaprwebapp-dev1-we --location westeurope

2) Command Line to load bicep file - use Bash
az deployment group create `
  --name tododaprwebapp `
  --resource-group rg-tododaprwebapp-dev1-we `
  --template-file main.bicep `
  --parameters location=westeurope location_suffix=we environment=dev1

*/

param location string = resourceGroup().location
param location_suffix string = 'we'
// For simplicity, we receive the env name as a parameter and we do not apply any special sizing with it
// Ideally Prod would be more powerful than Dev, so a parameters file would be a better solution
param environment string = 'dev1'

module cosmosdb './cosmosdb.bicep' = {
  name: 'cosmosdbDeployment'
  params: {
    location: location
    environment: environment
    location_suffix: location_suffix 
  }
  scope: resourceGroup()
}

module acr './acr.bicep' = {
  name: 'acrDeployment'
  params: {
    location: location
    environment: environment
    location_suffix: location_suffix 
  }
  scope: resourceGroup()
}

var environmentName = 'acaenv-tododaprwebapp-${environment}-${location_suffix}'

module acaEnv './acaenvironment.bicep' = {
  name: 'acaDeployment'
  params: {
    location: location
    environment: environment
    location_suffix: location_suffix 
    environmentName: environmentName
  }
  scope: resourceGroup()
}

var containerRegistryUrl = acr.outputs.loginServer
var containerRegistryUsername = acr.outputs.name

var acaApiName = 'dapr-api'
var acaApiNameImage = '${containerRegistryUrl}/${containerRegistryUsername}/${acaApiName}:latest'

var acaClientName = 'dapr-client'
var acaClientNameImage = '${containerRegistryUrl}/${containerRegistryUsername}/${acaClientName}:latest'

// var cosmosdbConnectionString = listKeys(cosmosdbResource.id, cosmosdbResource.apiVersion).primaryMasterKey
var cosmosdbConnectionString = cosmosdb.outputs.connectionString
var registryPassword = acr.outputs.password
// var registryPassword = 'FohO14ENTFIq6mZ80lQ/yePd+SDydosIhfxTDiDKHh+ACRBqAKbq'
param registryPassName string = 'registry-password'

module acaApi './containerApp.bicep' = {
  name: '${deployment().name}--${acaApiName}'
  dependsOn: [
    acaEnv
    acr
  ]
  params: {
    location: location
    containerAppName: acaApiName
    environmentId: acaEnv.outputs.id
    containerPort: 80
    containerImage: acaApiNameImage
    containerRegistry: containerRegistryUrl
    containerRegistryUsername: containerRegistryUsername
    isPrivateRegistry: true
    registryPassName: registryPassName
    isExternalIngress: true
    enableIngress: true
    minReplicas: 1
    secrets: [
      {
        name: registryPassName
        value: registryPassword
      }
      {
        name: 'cosmoskey'
        // listKeys(cosmosdbResource.id, cosmosdbResource.apiVersion).primaryMasterKey
        value: cosmosdbConnectionString
      }
    ]
    env: [
      {
        name: 'ConnectionString'
        secretRef: 'cosmoskey'
      }
      {
          name: 'CosmosDb__DatabaseName'
          value: 'Tasks'
      }
      {
          name: 'CosmosDb__ContainerName'
          value: 'Item'
      }
      {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
      }
    ]
    revisionMode:  'Single'
  }
  scope: resourceGroup()
}


module acaClient './containerApp.bicep' = {
  name: '${deployment().name}--${acaClientName}'
  dependsOn: [
    acaEnv
    acr
  ]
  params: {
    location: location
    containerAppName: acaClientName
    environmentId: acaEnv.outputs.id
    containerPort: 80
    containerImage: acaClientNameImage
    containerRegistry: containerRegistryUrl
    containerRegistryUsername: containerRegistryUsername
    isPrivateRegistry: true
    registryPassName: registryPassName
    isExternalIngress: true
    enableIngress: true
    minReplicas: 1
    secrets: [
      {
        name: registryPassName
        value: registryPassword
      }
    ]
    env: [
      {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
      }
    ]
    revisionMode:  'Single'
  }
  scope: resourceGroup()
}

var daprStateStoreName = '${environmentName}/todostatestore'

resource stateDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: daprStateStoreName
  dependsOn: [
    acaEnv
  ]
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    secrets: [
      {
        name: 'masterkey'
        value: cosmosdb.outputs.primaryMasterKey
      }
    ]
    metadata: [
      {
        name: 'url'
        value: cosmosdb.outputs.documentEndpoint
      }
      {
        name: 'database'
        value: 'Tasks'
      }
      {
        name: 'collection'
        value: 'Item'
      }
      {
        name: 'masterkey'
        secretRef: 'masterkey'
      }
    ]
    scopes: [
      'dapr-api'
    ]
  }
}
