targetScope = 'subscription'

resource blockOutsidePrivateEndpoint 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'blockOutsidePrivateEndpoint'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Block external private endpoint'
    description: 'Block external private endpoint'
    policyRule: {
      if: {
        allOf: [
          {
             field: 'type'
             equals: 'Microsoft.Storage/storageAccounts/privateEndpointConnections'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/privateEndpointConnections/privateLinkServiceConnectionState.status'
            equals: 'Approved'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/privateEndpointConnections/privateEndpoint.id'
            notLike: '[concat(subscription().id, \'/*\')]'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

module blockOutsidePrivateEndpointAssignment 'policyAssignment.bicep' = {
  name: 'blockOutsidePrivateEndpointAssignment'
  scope: resourceGroup('policy-security-rg')
  params: {
    policyId: blockOutsidePrivateEndpoint.id
  }
}
