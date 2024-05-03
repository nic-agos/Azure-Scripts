$header = "App Service Name;Location;Resource Group;Subscription;Authentication;Client Certificates;Azure Active Directory Registration;Net Framework Version;Php Version;Linux Fx Version;Python Version;Windows Fx Version;Http 2.0 Enabled;Min Tls Version;Ftp State;Https Only;VNet Integration;Private Endpoints"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $appServices = Get-AzWebApp

    foreach ($app in $appServices) {

        $currentTuple = ""

        $appServiceName = $app.Name
        $appServiceResourceGroup = $app.ResourceGroup
        $appServiceLocation = $app.Location

        $appServiceAuthentication = ""
        
        $appServiceAuthentication = az webapp auth show --resource-group $appServiceResourceGroup --name  $appServiceName --query enabled

        $info = (Get-AzWebApp -name $app.Name)

        $vnetIntegrationTemp = $info.VirtualNetworkSubnetId

        if($null -ne $vnetIntegrationTemp){

            $start = $vnetIntegrationTemp.indexOf('virtualNetworks/') + 16
            $end = $vnetIntegrationTemp.indexOf('subnets/')
            
            $vnetNameTemp = $vnetIntegrationTemp.Substring($start, ($end - $start)-1)
            
            $subnetNameTemp = $vnetIntegrationTemp.Split('/')[-1]

            $vnetIntegration = $vnetNameTemp + "/" + $subnetNameTemp

        }else {

            $vnetIntegration = ""

        }

        $appServiceClientCertificates = $info.ClientCertEnabled

        $appServiceAzureActiveDirectoryRegistrationTemp = $info.Identity

        if($null -ne $appServiceAzureActiveDirectoryRegistrationTemp){

            $appServiceAzureActiveDirectoryRegistration = $appServiceAzureActiveDirectoryRegistrationTemp

        }else{
            $appServiceAzureActiveDirectoryRegistration = "False"
        }
              
        $conf = $info.SiteConfig

        $appServiceId = $app.Id

        $appServicePrivateEndpointsTemp = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $appServiceId

        $appServicePrivateEndpoints = ""

        foreach($privateEndpoint in $appServicePrivateEndpointsTemp){

            $appServicePrivateEndpoints = $appServicePrivateEndpoints + $privateEndpoint.Name + "  "

        }

        $appServiceNetFrameworkVersion = $conf.NetFrameworkVersion
        $appServicePhpVersion = $conf.PhpVersion
        $appServiceLinuxFxVersion = $conf.LinuxFxVersion
        $appServicePythonVersion = $conf.PythonVersion
        $appServiceWindowsFxVersion = $conf.WindowsFxVersion
        $appServicHttp20Enabled = $conf.Http20Enabled
        $appServiceMinTlsVersion = $conf.MinTlsVersion
        $appServiceFtpsState = $conf.FtpsState

        $appServiceHttpsOnly = $info.HttpsOnly

        $currentTuple = "`n" +  
            $appServiceName + "; " +
            $appServiceLocation + "; " +
            $appServiceResourceGroup + "; " +
            $subscriptionName + "; " +
            $appServiceAuthentication + "; " +
            $appServiceClientCertificates + "; " +
            $appServiceAzureActiveDirectoryRegistration + "; " +
            $appServiceNetFrameworkVersion + "; " + 
            $appServicePhpVersion + "; " +
            $appServiceLinuxFxVersion + "; " +
            $appServicePythonVersion + "; " +
            $appServiceWindowsFxVersion + "; " +
            $appServicHttp20Enabled + "; " +
            $appServiceMinTlsVersion + "; " +
            $appServiceFtpsState + "; " +
            $appServiceHttpsOnly + "; " +
            $vnetIntegration + "; " +
            $appServicePrivateEndpoints
        
        $resultSet = $resultSet + $currentTuple

    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./AppServices_" + $date + ".csv"
$Result | Out-File -FilePath $path


