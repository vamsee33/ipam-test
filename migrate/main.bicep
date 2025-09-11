// Global parameters
targetScope = 'subscription'

// Existing Resource Object for Migration
type resourceObject = {
  appService: {
    appServiceName: string
    appServiceRG: string
  }
  appServicePlan: {
    appServicePlanName: string
    appServicePlanRG: string
  }
  cosmosAccount: {
    cosmosAccountName: string
    cosmosAccountRG: string
    cosmosContainerName: string
    cosmosDatabaseName: string
  }
  keyVault: {
    keyVaultName: string
    keyVaultRG: string
  }
  logAnalytics: {
    workspaceName: string
    workspaceRG: string
  }
  managedIdentity: {
    managedIdentityName: string
    managedIdentityRG: string
  }
  containerRegistry: {
    containerRegistryName: string?
    containerRegistryRG: string?
  }
}

@description('Deployment Location')
param location string = deployment().location

@description('Azure Cloud Enviroment')
param azureCloud string = 'AZURE_PUBLIC'

@description('Flag to Deploy Private Container Registry')
param privateAcr bool = false

@description('IPAM Resources')
param resourceDetails resourceObject

// Log Analytics Workspace
module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' ={
  name: 'logAnalyticsWorkspaceModule'
  scope: resourceGroup(resourceDetails.logAnalytics.workspaceRG)
  params: {
    location: location
    workspaceName: resourceDetails.logAnalytics.workspaceName
  }
}

// Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: resourceDetails.managedIdentity.managedIdentityName
  scope: resourceGroup(resourceDetails.managedIdentity.managedIdentityRG)
}

// Key Vault
module keyVault './modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  scope: resourceGroup(resourceDetails.keyVault.keyVaultRG)
  params: {
    location: location
    keyVaultName: resourceDetails.keyVault.keyVaultName
    identityPrincipalId:  managedIdentity.properties.principalId
    identityClientId:  managedIdentity.properties.clientId
    workspaceId: logAnalyticsWorkspace.outputs.workspaceId
  }
}

// Cosmos DB
module cosmos './modules/cosmos.bicep' = {
  name: 'cosmosModule'
  scope: resourceGroup(resourceDetails.cosmosAccount.cosmosAccountRG)
  params: {
    cosmosAccountName: resourceDetails.cosmosAccount.cosmosAccountName
    workspaceId: logAnalyticsWorkspace.outputs.workspaceId
    principalId: managedIdentity.properties.principalId
  }
}

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = if (privateAcr) {
  name: resourceDetails.containerRegistry.containerRegistryName!
  scope: resourceGroup(resourceDetails.containerRegistry.containerRegistryRG!)
}

// App Service
module appService './modules/appService.bicep' = {
  scope: resourceGroup(resourceDetails.appService.appServiceRG)
  name: 'appServiceModule'
  params: {
    location: location
    azureCloud: azureCloud
    appServiceName: resourceDetails.appService.appServiceName
    appServicePlanName: resourceDetails.appServicePlan.appServicePlanName
    keyVaultUri: keyVault.outputs.keyVaultUri
    cosmosDbUri: cosmos.outputs.cosmosDocumentEndpoint
    databaseName: resourceDetails.cosmosAccount.cosmosDatabaseName
    containerName: resourceDetails.cosmosAccount.cosmosContainerName
    managedIdentityId: managedIdentity.id
    managedIdentityClientId: managedIdentity.properties.clientId
    workspaceId: logAnalyticsWorkspace.outputs.workspaceId
    privateAcr: privateAcr
    privateAcrUri: privateAcr ? containerRegistry!.properties.loginServer : ''
  }
}

// Outputs
// output suffix string = uniqueString(guid)
// output subscriptionId string = subscription().subscriptionId
// output resourceGroupName string = resourceGroup.name
// output appServiceName string = deployAsFunc ? resourceNames.functionName : resourceNames.appServiceName
// output appServiceHostName string = deployAsFunc ? functionApp.outputs.functionAppHostName : appService.outputs.appServiceHostName
// output acrName string = privateAcr ? containerRegistry.outputs.acrName : ''
// output acrUri string = privateAcr ? containerRegistry.outputs.acrUri : ''
