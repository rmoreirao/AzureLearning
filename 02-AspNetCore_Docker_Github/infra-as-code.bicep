// 
/*
1) Command Line to execute bicep file: 
az group create --name rg-tododockerwebapp-dev5-we --location westeurope

2) Command Line to load bicep file - use Bash
az deployment group create \
  --name DeployDockerWebApp \
  --resource-group rg-tododockerwebapp-dev5-we \
  --template-file infra-as-code.bicep \
  --parameters location=westeurope location_suffix=we environment=dev5

*/

param location string = resourceGroup().location
param location_suffix string = 'we'
// For simplicity, we receive the env name as a parameter and we do not apply any special sizing with it
// Ideally Prod would be more powerful than Dev, so a parameters file would be a better solution
param environment string = 'dev3'

var webAppName = 'webapptododockerwebapp${environment}${location_suffix}'
var acrName = 'acrtododockerwebapp${environment}${location_suffix}'
var webAppLinuxFxVersion = 'DOCKER|${acrName}.azurecr.io/learning/tododockerwebapp:1.0'
var appServicePlanName_var = 'asp-tododockerwebapp-${environment}-${location_suffix}'
var cosmosDbName_var = 'cosmos-tododockerwebapp-${environment}-${location_suffix}'
var appInsightName = 'appi-tododockerwebapp-${environment}-${location_suffix}'


resource cosmosDbName 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: cosmosDbName_var
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
        locationName: 'West Europe'
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
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    maximumElasticWorkerCount: 1
    isSpot: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    reserved:true
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    appInsights
  ]
  properties: {
    enabled: true
    
    serverFarmId: appServicePlanName.id
    reserved:true
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      linuxFxVersion: webAppLinuxFxVersion
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
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: 1
    netFrameworkVersion: 'v4.0'
    linuxFxVersion:webAppLinuxFxVersion
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
  parent: webApp
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    ConnectionString: listConnectionStrings(cosmosDbName.id, '2019-12-12').connectionStrings[0].connectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    XDT_MicrosoftApplicationInsights_Mode: 'default'
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    DOCKER_REGISTRY_SERVER_URL: reference(acr.id, '2019-05-01').loginServer
    DOCKER_REGISTRY_SERVER_USERNAME: listCredentials(acr.id, '2019-05-01').username
    DOCKER_REGISTRY_SERVER_PASSWORD: listCredentials(acr.id, '2019-05-01').passwords[0].value
  }
}

resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp
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

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location 
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

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

output acrLoginServer string = acr.properties.loginServer
output webAppName string = webAppName
output appServicePlanName string = appServicePlanName_var
output cosmosDbName string = cosmosDbName_var
