// 
/*
1) Command Line to execute bicep file: 
az group create --name rg-todoacawebapp-dev1-we --location westeurope

2) Command Line to load bicep file - use Bash
az deployment group create `
  --name todoacawebapp `
  --resource-group rg-todoacawebapp-dev1-we `
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


module acaEnv './acaenvironment.bicep' = {
  name: 'acaDeployment'
  params: {
    location: location
    environment: environment
    location_suffix: location_suffix 
  }
  scope: resourceGroup()
}

var containerRegistryUrl = acr.outputs.loginServer
var containerRegistryUsername = acr.outputs.name

var acaApiName = 'aca-api'
var acaApiNameImage = '${containerRegistryUrl}/${containerRegistryUsername}/${acaApiName}:latest'

var acaClientName = 'aca-client'
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
        name: 'ToDoAPIUrl'
        value: 'https://${acaApi.outputs.fqdn}'
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
