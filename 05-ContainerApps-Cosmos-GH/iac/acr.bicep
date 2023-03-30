//The idea is to have one ACR and not specific to each environment
param environment string  = 'dev'
param location_suffix string = 'we'
param location string = 'westeurope'

var acrName = 'acrtodoacawebapp${location_suffix}${environment}'

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
