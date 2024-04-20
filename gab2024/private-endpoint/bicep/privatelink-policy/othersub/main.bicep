targetScope='subscription'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: 'westeurope'
  name: 'demo-rg'
}

module rgContent 'rgContent.bicep' = {
  name: 'rgContent'
  scope: rg
}
