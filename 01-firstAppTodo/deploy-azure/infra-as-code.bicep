param location string = 'westeurope'
param location_suffix string = 'we'
// For simplicity, we receive the env name as a parameter and we do not apply any special sizing with it
// Ideally Prod would be more powerful than Dev, so a parameters file would be a better solution
param environment string = 'dev3'
param subnetAddressPrefix string = '3'

var vnetName_var = 'vnet-firstapp-${environment}-${location_suffix}'
var vnetAdressSpace = '10.${subnetAddressPrefix}.0.0/16'
var subnetWebAppName = 'snet-firstappwebapp-${environment}-${location_suffix}'
var subnetWebAppAdressSpace = '10.${subnetAddressPrefix}.1.0/24'
var subnetCosmosDBName = 'snet-firstappdb-${environment}-${location_suffix}'
var subnetCosmosDBAdressSpace = '10.${subnetAddressPrefix}.2.0/24'
var webAppName_var = 'webapptodofirstapp${environment}${location_suffix}'
var appServicePlanName_var = 'asp-webapptodofirstapp-${environment}-${location_suffix}'
var cosmosDbName_var = 'cosmos-firstapp-${environment}-${location_suffix}'

resource vnetName 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAdressSpace
      ]
    }
    subnets: [
      {
        name: subnetCosmosDBName
        properties: {
          addressPrefix: subnetCosmosDBAdressSpace
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureCosmosDB'
              locations: [
                '*'
              ]
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnetWebAppName
        properties: {
          addressPrefix: subnetWebAppAdressSpace
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource vnetName_subnetCosmosDBName 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnetName
  name: subnetCosmosDBName
  properties: {
    addressPrefix: subnetCosmosDBAdressSpace
    serviceEndpoints: [
      {
        service: 'Microsoft.AzureCosmosDB'
        locations: [
          '*'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vnetName_subnetWebAppName 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnetName
  name: subnetWebAppName
  properties: {
    addressPrefix: subnetWebAppAdressSpace
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource cosmosDbName 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: cosmosDbName_var
  location: 'West Europe'
  tags: {
    defaultExperience: 'Core (SQL)'
    'hidden-cosmos-mmspecial': ''
  }
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
      {
        id: vnetName_subnetCosmosDBName.id
        ignoreMissingVNetServiceEndpoint: false
      }
    ]
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: 'West Europe'
        provisioningState: 'Succeeded'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: []
    ipRules: [
      {
        ipAddressOrRange: '177.142.137.53'
      }
      {
        ipAddressOrRange: '104.42.195.92'
      }
      {
        ipAddressOrRange: '40.76.54.131'
      }
      {
        ipAddressOrRange: '52.176.6.30'
      }
      {
        ipAddressOrRange: '52.169.50.45'
      }
      {
        ipAddressOrRange: '52.187.184.26'
      }
      {
        ipAddressOrRange: '0.0.0.0'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
    networkAclBypassResourceIds: []
    diagnosticLogSettings: {
      enableFullTextQuery: 'None'
    }
    capacity: {
      totalThroughputLimit: 1000
    }
  }
}

resource cosmosDbName_Tasks 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-02-15-preview' = {
  parent: cosmosDbName
  name: 'Tasks'
  properties: {
    resource: {
      id: 'Tasks'
    }
  }
}

// resource cosmosDbName_00000000_0000_0000_0000_000000000001 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-02-15-preview' = {
//   parent: cosmosDbName
//   name: '00000000-0000-0000-0000-000000000001'
//   properties: {
//     roleName: 'Cosmos DB Built-in Data Reader'
//     type: 'BuiltInRole'
//     assignableScopes: [
//       cosmosDbName.id
//     ]
//     permissions: [
//       {
//         dataActions: [
//           'Microsoft.DocumentDB/databaseAccounts/readMetadata'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
//         ]
//         notDataActions: []
//       }
//     ]
//   }
// }

// resource cosmosDbName_00000000_0000_0000_0000_000000000002 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-02-15-preview' = {
//   parent: cosmosDbName
//   name: '00000000-0000-0000-0000-000000000002'
//   properties: {
//     roleName: 'Cosmos DB Built-in Data Contributor'
//     type: 'BuiltInRole'
//     assignableScopes: [
//       cosmosDbName.id
//     ]
//     permissions: [
//       {
//         dataActions: [
//           'Microsoft.DocumentDB/databaseAccounts/readMetadata'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
//         ]
//         notDataActions: []
//       }
//     ]
//   }
// }

resource appServicePlanName 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName_var
  location: 'West Europe'
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource webAppName 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName_var
  location: 'West Europe'
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName_var}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName_var}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlanName.id
    vnetRouteAllEnabled: false
    siteConfig: {
      appSettings: [
        {
          name: 'ConnectionString'
          value: listConnectionStrings(cosmosDbName.id, '2019-12-12').connectionStrings[0].connectionString
        }
      ]
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// resource webAppName_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
//   parent: webAppName
//   name: 'ftp'
//   location: 'West Europe'
//   properties: {
//     allow: true
//   }
// }

// resource webAppName_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
//   parent: webAppName
//   name: 'scm'
//   location: 'West Europe'
//   properties: {
//     allow: true
//   }
// }

resource webAppName_web 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webAppName
  name: 'web'
  location: 'West Europe'
  properties: {
    numberOfWorkers: 1
    netFrameworkVersion: 'v6.0'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    detailedErrorLoggingEnabled: false
    use32BitWorkerProcess: true
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {
    }
  }
}

resource webAppName_webAppName_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: webAppName
  name: '${webAppName_var}.azurewebsites.net'
  location: 'West Europe'
  properties: {
    siteName: 'webapptodofirstappdev'
    hostNameType: 'Verified'
  }
}

// resource webAppName_Microsoft_AspNetCore_AzureAppServices_SiteExtension 'Microsoft.Web/sites/siteextensions@2022-03-01' = {
//   parent: webAppName
//   name: 'Microsoft.AspNetCore.AzureAppServices.SiteExtension'
//   location: 'West Europe'
// }

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'AppInsights${webAppName.name}'
  location: location
  tags: {
    'hidden-link:${webAppName.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output vnetName string = vnetName_var
output vnetAdressSpace string = vnetAdressSpace
output subnetWebAppName string = subnetWebAppName
output subnetWebAppAdressSpace string = subnetWebAppAdressSpace
output subnetCosmosDBName string = subnetCosmosDBName
output subnetCosmosDBAdressSpace string = subnetCosmosDBAdressSpace
output webAppName string = webAppName_var
output appServicePlanName string = appServicePlanName_var
output cosmosDbName string = cosmosDbName_var
