# Get all Azure Subscriptions
$Subs = Get-AzSubscription
# Set array
$DiagResults = @()
# Loop through all Azure Subscriptions
foreach ($Sub in $Subs) {
    Set-AzContext $Sub.id | Out-Null
    Write-Host "Processing Subscription:" $($Sub).name
    # Get all Azure resources for current subscription
    $Resources = Get-AZResource
    # Get all Azure resources which have Diagnostic settings enabled and configured
    foreach ($res in $Resources) {
        $resId = $res.ResourceId
        $DiagSettings = Get-AzDiagnosticSetting -ResourceId $resId -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $null }
        foreach ($diag in $DiagSettings) {
            If ($diag.StorageAccountId) {
                [string]$StorageAccountId= $diag.StorageAccountId
                [string]$storageAccountName = $StorageAccountId.Split('/')[-1]
            }
            If ($diag.EventHubAuthorizationRuleId) {
                [string]$EventHubId = $diag.EventHubAuthorizationRuleId
                [string]$EventHubName = $EventHubId.Split('/')[-3]
            }
            If ($diag.WorkspaceId) {
                [string]$WorkspaceId = $diag.WorkspaceId
                [string]$WorkspaceName = $WorkspaceId.Split('/')[-1]
            }
            # Store all results for resource in PS Object
            $item = [PSCustomObject]@{
                ResourceName = $res.name
                DiagnosticSettingsName = $diag.name
                StorageAccountName =  $StorageAccountName
                EventHubName =  $EventHubName
                WorkspaceName =  $WorkspaceName
                # Extracting delatied porerties into string format.
                Metrics = ($diag.Metric | ConvertTo-Json -Compress | Out-String).Trim()
                Logs =  ($diag.Log | ConvertTo-Json -Compress | Out-String).Trim()
                Subscription = $Sub.Name
                ResourceId = $resId
                DiagnosticSettingsId = $diag.Id
                StorageAccountId =  $StorageAccountId
                EventHubId =  $EventHubId
                WorkspaceId = $WorkspaceId
            }
            # Add PS Object to array
            $DiagResults += $item
        }
    }
    
}
# Save Diagnostic settings to CSV as tabular data
$DiagResults | Export-Csv -Force -Path ".\AzureResourceDiagnosticSettings-$(get-date -f yyyy-MM-dd-HHmm).csv"