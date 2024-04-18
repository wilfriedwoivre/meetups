targetScope = 'subscription'

resource rgAppendDeny 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'eventhub-append-deny-rg'
  location: 'westeurope'
  tags: {
    AutoDelete: 'true'
    ExpirationDate: '2024-04-15'
  }
}

resource rgModify 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'eventhub-modify-rg'
  location: 'westeurope'
  tags: {
    AutoDelete: 'true'
    ExpirationDate: '2024-04-15'
  }
}

resource denyPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'deny-policy-definition'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.EventHub/namespaces'
          }
          {
            field: 'Microsoft.EventHub/namespaces/minimumTlsVersion'
            exists: true
          }
          {
            field: 'Microsoft.EventHub/namespaces/minimumTlsVersion'
            notEquals: '1.2'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}


module denyPolicyAssignment 'policyAssignment.bicep' = {
  name: 'deny-policy-assignment'
  scope: rgAppendDeny
  params: {
    policyId: denyPolicyDefinition.id
  }
}


resource appendPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'append-policy-definition'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.EventHub/namespaces'
          }
          {
            field: 'Microsoft.EventHub/namespaces/minimumTlsVersion'
            exists: false
          }
        ]
      }
      then: {
        effect: 'append'
        details: [
          {
            field: 'Microsoft.EventHub/namespaces/minimumTlsVersion'
            value: '1.2'
          }
        ]
      }
    }
  }
}


module appendPolicyAssignment 'policyAssignment.bicep' = {
  name: 'append-policy-assignment'
  scope: rgAppendDeny
  params: {
    policyId: appendPolicyDefinition.id
  }
}

resource modifyPolicyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'modify-policy-definition'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.EventHub/namespaces'
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.EventHub/namespaces/minimumTlsVersion'
              value: '1.2'
            }
          ]
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
        }
      }
    }
  }
}

module modifyPolicyAssignment 'policyAssignment.bicep' = {
  name: 'modify-policy-assignment'
  scope: rgModify
  params: {
    policyId: modifyPolicyDefinition.id
    useIdentity: true
  }
}

module eventhubAppendDeny 'eventhub.bicep' = {
  name: 'eventhubappenddeny'
  scope: rgAppendDeny
  dependsOn: [
    denyPolicyAssignment
    appendPolicyAssignment
  ]
}

module eventhubModify 'eventhub.bicep' = {
  name: 'eventhubModify'
  scope: rgModify
  dependsOn: [
    modifyPolicyAssignment
  ]
}
