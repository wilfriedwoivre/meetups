# Create image
docker build -t acisample .

#Tag image
docker tag acisample ($registry.LoginServer + '/acisample:v1')

#Push image
docker push ($registry.LoginServer + '/acisample:v1')

# Create Azure Storage account
$storageAccountName = ''
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind Storage
$storageKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName


# Run ACI
$securedPassword = ConvertTo-SecureString $credentials.Password -AsPlainText -Force
$psCreds = New-Object System.Management.Automation.PSCredential($credentials.Username, $securedPassword)
New-AzureRmContainerGroup -ResourceGroupName $resourceGroupName -Name demo -Image ($registry.LoginServer + '/acisample:v1') -RegistryCredential $psCreds -Location $location -RestartPolicy OnFailure -EnvironmentVariable @{"URL_TO_SCAN"="http://blog.woivre.fr";"AZURE_STORAGE_NAME"=$storageAccountName;"AZURE_STORAGE_KEY"=$storageKeys[0].Value;"MIN_LENGTH"=5}