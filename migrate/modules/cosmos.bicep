@description('CosmosDB Account Name')
param cosmosAccountName string

@description('Log Analytics Workspace ID')
param workspaceId string

@description('Managed Identity PrincipalId')
param principalId string

var dbContributor = '00000000-0000-0000-0000-000000000002'
var dbContributorId = '${resourceGroup().id}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosAccount.name}/sqlRoleDefinitions/${dbContributor}'
var dbContributorRoleAssignmentId = guid(dbContributor, principalId, cosmosAccount.id)

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' existing = {
  name: cosmosAccountName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagSettings'
  scope: cosmosAccount
  properties: {
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    logAnalyticsDestinationType: 'Dedicated'
    workspaceId: workspaceId
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: dbContributorRoleAssignmentId
  parent: cosmosAccount
  properties: {
    roleDefinitionId: dbContributorId
    principalId: principalId
    scope: cosmosAccount.id
  }
}

output cosmosDocumentEndpoint string = cosmosAccount.properties.documentEndpoint
