param environment string  = 'dev'
param location_suffix string = 'we'
param location string = 'westeurope'

var cosmosDbName = 'cosmos-tododaprwebapp-${environment}-${location_suffix}'

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: cosmosDbName
  location: location
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
    isVirtualNetworkFilterEnabled: false
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
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: []
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
  parent: cosmosDb
  name: 'Tasks'
  properties: {
    resource: {
      id: 'Tasks'
    }
  }
}

output name string = cosmosDbName
output connectionString string = cosmosDb.listConnectionStrings().connectionStrings[0].connectionString
output documentEndpoint string = cosmosDb.properties.documentEndpoint
output primaryMasterKey string = listKeys(cosmosDb.id, cosmosDb.apiVersion).primaryMasterKey
