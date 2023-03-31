/*
1) Command Line to execute bicep file: 
az group create --name rg-tododaprwebapp-dev1-we --location westeurope

2) Command Line to load bicep file - use Bash
az deployment group create `
  --name tododaprwebapp `
  --resource-group rg-tododaprwebapp-dev1-we `
  --template-file acr.bicep `
  --parameters location=westeurope location_suffix=we environment=dev1

*/

//The idea is to have one ACR and not specific to each environment
param environment string  = 'dev'
param location_suffix string = 'we'
param location string = 'westeurope'

var acrName = 'acrtododaprwebapp${location_suffix}${environment}'

// azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output loginServer string = acr.properties.loginServer
output name string = acrName
output password string = acr.listCredentials().passwords[0].value
