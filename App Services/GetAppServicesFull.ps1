$header = "App Service Name;Location;Resource Group;Subscription;Authentication;Client Certificates;Azure Active Directory Registration;Net Framework Version;PHP Version;Linux Fx Version;Python Version;Windows Fx Version;Http 2.0 Enabled;Min Tls Version;Ftps State;Https Only;Diagnostic Settings Name;Logs;Metrics;Storage Account Name;Event Hub Name;Workspace Name;VNet Integration;Private Endpoints"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $appServices = Get-AzWebApp

    foreach ($app in $appServices) {

        $appServiceName = $app.Name
        $appServiceResourceGroup = $app.ResourceGroup
        $appServiceLocation = $app.Location

        $appServiceAuthentication = ""
        
        $appServiceAuthentication = az webapp auth show --resource-group $appServiceResourceGroup --name  $appServiceName --query enabled

        $info = (Get-AzWebApp -name $app.Name)

        $appServiceHttpsOnly = $info.HttpsOnly

        $vnetIntegrationTemp = $info.VirtualNetworkSubnetId

        $vnetIntegration = ""

        if($null -ne $vnetIntegrationTemp){

            $start = $vnetIntegrationTemp.indexOf('virtualNetworks/') + 16
            $end = $vnetIntegrationTemp.indexOf('subnets/')
            
            $vnetNameTemp = $vnetIntegrationTemp.Substring($start, ($end - $start)-1)
            
            $subnetNameTemp = $vnetIntegrationTemp.Split('/')[-1]

            $vnetIntegration = $vnetNameTemp + "/" + $subnetNameTemp

        }

        $appServiceClientCertificates = ""

        $appServiceClientCertificates = $info.ClientCertEnabled

        $appServiceAzureActiveDirectoryRegistrationTemp = $info.Identity

        $appServiceAzureActiveDirectoryRegistration = ""

        if($null -ne $appServiceAzureActiveDirectoryRegistrationTemp){

            $appServiceAzureActiveDirectoryRegistration = $appServiceAzureActiveDirectoryRegistrationTemp

        }else{
            $appServiceAzureActiveDirectoryRegistration = "False"
        }

        $appServiceId = ""
        
        $appServiceId = $app.Id

        $conf = ""

        $conf = $info.SiteConfig

        $appServiceNetFrameworkVersion = $conf.NetFrameworkVersion
        $appServicePhpVersion = $conf.PhpVersion
        $appServiceLinuxFxVersion = $conf.LinuxFxVersion
        $appServicePythonVersion = $conf.PythonVersion
        $appServiceWindowsFxVersion = $conf.WindowsFxVersion
        $appServicHttp20Enabled = $conf.Http20Enabled
        $appServiceMinTlsVersion = $conf.MinTlsVersion
        $appServiceFtpsState = $conf.FtpsState

        $appServiceId = $app.Id

        $appServicePrivateEndpointsTemp = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $appServiceId

        $appServicePrivateEndpoints = ""

        foreach($privateEndpoint in $appServicePrivateEndpointsTemp){

            $appServicePrivateEndpoints = $appServicePrivateEndpoints + $privateEndpoint.Name + "  "

        }

        $diagnosticSettings = $null

        $diagnosticSettings = Get-AzDiagnosticSetting -ResourceId $appServiceId

        if($null -ne $diagnosticSettings){

            foreach($diag in $diagnosticSettings){

                $currentTuple = ""

                $diagnosticSettingsName = ""

                $diagnosticSettingsName = $diag.Name

                $logs = ""

                $appServiceLogs = $diag.Log

                foreach ($log in $appServiceLogs){

                    $logCategory = $log.Category
                    $logStatus = $log.Enabled

                    $logs = $logs + ("[" + $logCategory + " : " + $logStatus + "]")

                }

                $metrics = ""

                $appServiceMetrics = $diag.Metric

                foreach($metric in $appServiceMetrics){

                    $metricCategory = $metric.Category
                    $metricStatus = $metric.Enabled

                    $metrics = $metrics + ("[" + $metricCategory + " : " + $metricStatus + "]")

                }

                $storageAccountId = $null
                $eventHubId = $null
                $workspaceId = $null

                $storageAccountName = ""
                $eventHubName = ""
                $workspaceName = ""

                $storageAccountId = $diag.StorageAccountId
                $eventHubId = $diag.EventHubAuthorizationRuleId
                $workspaceId = $diag.WorkspaceId

                If ($null -ne $storageAccountId) {

                    $storageAccountName = $storageAccountId.Split('/')[-1]
                }

                If ($null -ne $eventHubId) {
                    $eventHubName = $eventHubId.Split('/')[-3]
                }

                If ($null -ne $workspaceId) {
                    
                    $workspaceName = $workspaceId.Split('/')[-1]
                }


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
                    $diagnosticSettingsName + "; " +
                    $logs + "; " +
                    $metrics + "; " +
                    $storageAccountName + "; " +
                    $eventHubName + "; " +
                    $workspaceName + "; " +
                    $vnetIntegration + "; " +
                    $appServicePrivateEndpoints
        
                $resultSet = $resultSet + $currentTuple

            }
            
        }else{

            $currentTuple = ""

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
                    "; " +
                    "; " +
                    "; " +
                    "; " +
                    "; " +
                    "; " +
                    $vnetIntegration + "; " +
                    $appServicePrivateEndpoints
        
                $resultSet = $resultSet + $currentTuple

        }

    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./AppServicesFull_" + $date + ".csv"
$Result | Out-File -FilePath $path


