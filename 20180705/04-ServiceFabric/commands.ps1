# Backend build
docker build -t sfbackendsample .\backend\

#Tag image
docker tag sfbackendsample ($registry.LoginServer + '/sfbackendsample:v1')

#Push image
docker push ($registry.LoginServer + '/sfbackendsample:v1')

# frontend build
docker build -t sffrontendsample .\frontend\

#Tag image
docker tag sffrontendsample ($registry.LoginServer + '/sffrontendsample:v1')

#Push image
docker push ($registry.LoginServer + '/sffrontendsample:v1')


# Create Party cluster
# https://try.servicefabric.azure.com/

# Connect Party cluster
$url = "lnx2436sscv7bs.westus.cloudapp.azure.com"

$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Subject -eq "cn=$url"} 
Connect-ServiceFabricCluster -ConnectionEndpoint "$($url):19000" -KeepAliveIntervalInSec 10 -X509Credential -ServerCertThumbprint $cert.Thumbprint -FindType 'FindByThumbprint' -FindValue $cert.Thumbprint -StoreLocation 'CurrentUser' -StoreName 'My' -Verbose

$credentials.Password | Clip

# Add Application
$AppPath = ".\SFContainerSample\SFContainerSample"
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $AppPath -ApplicationPackagePathInImageStore SFContainerSample
Register-ServiceFabricApplicationType SFContainerSample
New-ServiceFabricApplication fabric:/SFContainerSample SFContainerSampleType 1.0.0


# Remove Application
Remove-ServiceFabricApplication fabric:/SFContainerSample -Force
Unregister-ServiceFabricApplicationType SFContainerSampleType -ApplicationTypeVersion 1.0.0 -Force
Remove-ServiceFabricApplicationPackage SFContainerSample