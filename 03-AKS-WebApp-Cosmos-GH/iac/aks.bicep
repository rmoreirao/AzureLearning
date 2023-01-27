/*
Deploy AKS  bicep

az deployment group create \
  --name DeployShoppingInfra \
  --resource-group rg-shoppingwebapprmoreirao-prod-we \
  --template-file aks.bicep \
  --parameters location_suffix=we

*/

param environment string = 'dev1'
param location_suffix string = 'we'

@description('The name of the Managed Cluster resource.')
param aksClusterName string = 'aks-todoakswebapp-${environment}-${location_suffix}'

@description('The location of AKS resource.')
param location string = resourceGroup().location

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'todoakswebapp${environment}${location_suffix}'

@description('The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(100)
param agentCount int = 1

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_D2s_v3'


param acrName string = 'acrtodoakswebapp${location_suffix}'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  location: location
  name: aksClusterName
  tags: {
    displayname: 'AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
      {
        name: 'workloads'
        osDiskSizeGB: 128
        count: 3
        vmSize: agentVMSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
  }
}

// Check code reference here: https://www.willvelida.com/posts/deploying-aks-with-acr-in-bicep/
// Here were are granting access from AKS to the ACR created
// CI CD User in Azure needs Contributor and User Access Administrator roles

var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrName
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksCluster.id, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: acrPullRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

output controlPlaneFQDN string = aksCluster.properties.fqdn
output aksClusterName string = aksCluster.name



