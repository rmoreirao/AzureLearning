param location string = 'westeurope'
param location_suffix string = 'we'
// For simplicity, we receive the env name as a parameter and we do not apply any special sizing with it
// Ideally Prod would be more powerful than Dev, so a parameters file would be a better solution
param environment string = 'dev3'
param subnetAddressPrefix string = '3'

var webAppName_var = 'webapptodofirstapp${environment}${location_suffix}'
var appServicePlanName_var = 'asp-webapptodofirstapp-${environment}-${location_suffix}'
var cosmosDbName_var = 'cosmos-firstapp-${environment}-${location_suffix}'
var appInsightName = 'appi-webapptodofirstapp-${environment}-${location_suffix}'



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
    maximumElasticWorkerCount: 1
    isSpot: false
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
    
    serverFarmId: appServicePlanName.id
    siteConfig: {
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
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    azureStorageAccounts: {
    }
  }
}



resource appServiceLogging 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webAppName
  name: 'appsettings'
  properties: {
    ConnectionString: listConnectionStrings(cosmosDbName.id, '2019-12-12').connectionStrings[0].connectionString
  }
}

// this is to add app insights to Kudu app, but this is generating some exception
// resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
//   parent: webAppName
//   name: 'Microsoft.ApplicationInsights.AzureWebSites'
//   dependsOn: [
//     appInsights
//   ]
// }

resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webAppName
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 40
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}


output webAppName string = webAppName_var
output appServicePlanName string = appServicePlanName_var
output cosmosDbName string = cosmosDbName_var
