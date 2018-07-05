#Connect-AzureRmAccount 

# Create Resource Group
$resourceGroupName = ''
$location = 'WestEurope'
New-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Location $location

# Create Registry
$registryName = ''
New-AzureRmContainerRegistry -ResourceGroupName $resourceGroupName -Name $registryName -Location $location -EnableAdminUser -Sku Basic 

# Register Credentials to docker
$registry = Get-AzureRmContainerRegistry -ResourceGroupName $resourceGroupName -Name $registryName
$credentials = Get-AzureRmContainerRegistryCredential -Registry $registry

docker login $registry.LoginServer -u $credentials.Username -p $credentials.Password