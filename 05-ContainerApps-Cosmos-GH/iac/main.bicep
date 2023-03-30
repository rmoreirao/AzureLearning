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

var containerRegistry = acr.outputs.loginServer
var containerRegistryUsername = acr.outputs.name

var acaApiName = 'aca-api'
var acaApiNameImage = '${containerRegistry}/${acaApiName}:latest'

var acaClientName = 'aca-client'
var acaClientNameImage = '${containerRegistry}/${acaClientName}:latest'

// var cosmosdbConnectionString = listKeys(cosmosdbResource.id, cosmosdbResource.apiVersion).primaryMasterKey
var cosmosdbConnectionString = cosmosdb.outputs.connectionString
var registryPassword = acr.outputs.password
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
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    isPrivateRegistry: true
    registryPassName: registryPassName
    isExternalIngress: false
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
        name: 'ApplicationInsights__ConnectionString'
        secretRef: 'cosmoskey'
      }
    ]
    revisionMode:  'Single'
  }
  scope: resourceGroup()
}

