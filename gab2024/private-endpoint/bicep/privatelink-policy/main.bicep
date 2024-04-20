targetScope = 'subscription'
param expirationDate string = utcNow('yyyy-MM-dd')

resource rgPolicy 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'policy-security-rg'
  location: 'northeurope'
  tags: {
    AutoDelete: 'true'
    ExpirationDate: expirationDate
  }
}

resource blockExternalPrivateLink 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'limit-private-endpoint-external-creation'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Limit private endpoint external creation'
    description: 'This policy limits the creation of private endpoints to only allow private endpoints to be created with a private link service in the same subscription.'
    metadata: {
      category: 'Security'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/privateEndpoints'
          }
          {
            allOf: [
              {
                field: 'Microsoft.Network/privateEndpoints/manualPrivateLinkServiceConnections'
                exists: 'true'
              }
              {
                count: {
                  field: 'Microsoft.Network/privateEndpoints/manualPrivateLinkServiceConnections[*]'
                }
                greater: 0
              }
              {
                field: 'Microsoft.Network/privateEndpoints/manualPrivateLinkServiceConnections[*].privateLinkServiceId'
                notLike: '[concat(subscription().id, \'/*\')]'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

module blockExternalPrivateLinkAssign 'policyAssignment.bicep' = {
  name: 'blockExternalPrivateLinkAssign'
  scope: rgPolicy
  params: {
    policyId: blockExternalPrivateLink.id
  }
}

resource blockExternalPrivateLinkServiceConnection 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'limit-private-link-service-connection-external-creation'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Limit private link service connection external creation'
    description: 'This policy limits the creation of private link service connections to only allow private link service connections to be created with a private endpoint in the same subscription.'
    metadata: {
      category: 'Security'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/privateEndpoints'
          }
          {
            field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections'
            exists: 'true'
          }
          {
            field: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].privateLinkServiceId'
            notContains: '[subscription().id]'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

module blockExternalPrivateLinkServiceAssign 'policyAssignment.bicep' = {
  name: 'blockExternalPrivateLinkServiceAssign'
  scope: rgPolicy
  params: {
    policyId: blockExternalPrivateLinkServiceConnection.id
  }
}


module rgContent 'rgContent.bicep' = {
  name: 'rgContent'
  scope: rgPolicy
}
