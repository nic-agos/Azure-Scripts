$header = "App Service Name; Location; Resource Group; Subscription; Diagnostic Settings Name; Logs; Metrics; Storage Account Name; Event Hub Name; Workspace Name"

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

        $appServiceId = ""
        
        $appServiceId = $app.Id

        $appServiceId = $app.Id

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
                    $diagnosticSettingsName + "; " +
                    $logs + "; " +
                    $metrics + "; " +
                    $storageAccountName + "; " +
                    $eventHubName + "; " +
                    $workspaceName + "; "
        
                $resultSet = $resultSet + $currentTuple

            }
            
        }

    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./AppServicesDiagnosticSettings_" + $date + ".csv"
$Result | Out-File -FilePath $path


