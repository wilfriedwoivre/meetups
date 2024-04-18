param policyId string
param useIdentity bool = false

resource PolicyAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'policy-assignment-${uniqueString(resourceGroup().id, policyId)}'
  identity: useIdentity ? {
    type: 'SystemAssigned'
  } : null
  location: resourceGroup().location
  properties: {
    policyDefinitionId: policyId

  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (useIdentity) {
  name: guid(policyId, subscription().subscriptionId)
  properties: {
    principalId: PolicyAssignment.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
}


