targetScope = 'subscription'
param expirationDate string = utcNow('yyyy-MM-dd')

resource rgPrivateEndpoint 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'privateendpoint-vpn-p2s-rg'
  location: 'northeurope'
  tags: {
    AutoDelete: 'true'
    ExpirationDate: expirationDate
  }
}

module rgContent 'rgPrivateEndpoint.bicep' = {
  name: 'rgContent'
  scope: rgPrivateEndpoint
}
