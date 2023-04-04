param location string = 'westeurope'

param containerAppName string
param environmentId string 
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param isPrivateRegistry bool
param registryPassName string
param enableIngress bool 
param minReplicas int = 0
param secrets array = []
param env array = []
param revisionMode string = 'Single'

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: secrets
      registries: isPrivateRegistry ? [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registryPassName
        }
      ] : null
      ingress: enableIngress ? {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      } : null
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 2
      }
    }
  }
}

// var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
// resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
//   name: containerRegistryUsername
// }

// resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, aksCluster.id, acrPullRoleDefinitionId)
//   scope: acr
//   properties: {
//     principalId: containerApp.properties.identityProfile.kubeletidentity.objectId
//     roleDefinitionId: acrPullRoleDefinitionId
//     principalType: 'ServicePrincipal'
//   }
// }

output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
