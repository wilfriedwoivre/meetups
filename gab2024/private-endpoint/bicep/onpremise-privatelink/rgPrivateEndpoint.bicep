resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-privateendpoint-vpn-p2s-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/20'
      ]
    }
    subnets: [
      {
        name: 'privateendpoint-subnets'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'privateresolver-inbound-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'privateresolver-outbound-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

resource privateDnsZoneBlob 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${uniqueString(vnet.id)}'
  parent: privateDnsZoneBlob
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'storage${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
}

resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'storage-private-endpoint-${uniqueString(resourceGroup().id, storage.id)}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: vnet.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: 'blob'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource record 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: storage.name
  parent: privateDnsZoneBlob
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: storagePrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
      }
    ]
  }
}

resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: '${deployment().name}-dns-resolver'
  location: resourceGroup().location
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource inbountEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: resolver
  location: resourceGroup().location
  name: '${deployment().name}-inbound-endpoint'
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: vnet.properties.subnets[1].id
        }
      }
    ]
  }
}

resource outbound 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: resolver
  location: resourceGroup().location
  name: '${deployment().name}-outbound-endpoint'
  properties: {
    subnet: {
      id: vnet.properties.subnets[2].id
    }
  }
}

resource ruleset 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: '${deployment().name}-ruleset'
  location: resourceGroup().location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outbound.id
      }
    ]
  }
}

resource vnetLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: ruleset
  name: '${deployment().name}-vnet-link'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'gwy-${uniqueString(resourceGroup().id)}-ip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource gwy 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: '${deployment().name}-gwy'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[3].id
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw2AZ'
      tier: 'VpnGw2AZ'
    }
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    gatewayType: 'Vpn'
    vpnGatewayGeneration: 'Generation2'
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '10.10.8.0/24'
        ]
      }
      vpnClientRootCertificates: [
        {
          name: 'vpn-certificat'
          properties: {
            publicCertData: loadTextContent('vpn-certificat.cer', 'utf-8')
          }
        }
      ]
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientProtocols: [
        'IkeV2'
        'SSTP'
      ]
    }
  }
}

