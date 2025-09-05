using './main.bicep'

param resourceDetails = {
  keyVault: {
    keyVaultRG: '<KEYVAILT RESOURCE GROUP>'
    keyVaultName: '<KEYVAULT NAME>'
  }
  logAnalytics: {
    workspaceRG: '<LOG ANALYTICS RESOURCE GROUP>'
    workspaceName: '<LOG ANALYTICS WORKSPACE NAME>'
  }
  managedIdentity: {
    managedIdentityRG: '<MANAGED IDENTITY RESOURCE GROUP>'
    managedIdentityName: '<MANAGED IDENTITY NAME>'
  }
  appServicePlan: {
    appServicePlanRG: '<APP SERVICE PLAN RESOURCE GROUP>'
    appServicePlanName: '<APP SERVICE PLAN NAME>'
  }
  appService: {
    appServiceRG: '<APP SERVICE RESOURCE GROUP>'
    appServiceName: '<APP SERVICE NAME>'
  }
  cosmosAccount: {
    cosmosAccountRG: '<COSMOS ACCOUNT RESOURCE GROUP>'
    cosmosAccountName: '<COSMOS ACCOUNT NAME>'
    cosmosDatabaseName: '<COSMOS DATABASE NAME> | ipam-db'
    cosmosContainerName: '<COSMOS CONTAINER NAME> | ipam-ctr'
  }
  containerRegistry: {
    containerRegistryRG: '<CONTAINER REGISTRY RESOURCE GROUP> | NULL'
    containerRegistryName: '<CONTAINER REGISTRY NAME> | NULL'
  }
}
