#IMPORTANTE: per visualizzare le informazioni è necessario avere il ruolo di Key Vault Reader
 
$result = @()
 
# Get all Azure Subscriptions
$subscriptions = Get-AzSubscription
 
foreach ($subscription in $subscriptions) {
 
    $subscriptionName = $subscription.Name
 
    Select-AzSubscription -SubscriptionName $subscriptionName
 
    $vaults = Get-AzKeyVault
 
    foreach($vault in $vaults){
 
        $keyVaultName = $vault.VaultName
        $resourceGroupName = $vault.ResourceGroupName
        $keyVaultLocation = $vault.Location
 
        $secrets = Get-AzKeyVaultSecret -VaultName $keyVaultName
 
        $certificates = Get-AzKeyVaultCertificate -VaultName $keyVaultName
 
        $keys = Get-AzKeyVaultKey -VaultName $keyVaultName
 
        $modifiedCertificateIDs = [System.Collections.ArrayList]@()
 
        foreach($secret in $secrets){
 
            if($secret.ContentType -ne "application/x-pkcs12"){
 
                $type = "Secret"
 
                $secretName = $secret.Name
                $secretId = $secret.Id
                $secretEnabled = $secret.Enabled
 
                $secretExpirationDateTime = $secret.Expires
 
                if ($null -ne $secretExpirationDateTime){
 
                    $secretExpirationDate = $secretExpirationDateTime.ToString("dd/MM/yyyy")
                    # $secretExpirationTime = $secretExpirationDateTime.ToString("HH:mm:ss")
 
                }else {
                    $secretExpirationDate = "No expiration"
                }
 
 
                $secretCreationDateTime = $secret.Created
                $secretCreationDate = $secretCreationDateTime.ToString("dd/MM/yyyy")
                # $secretCreationTime = $secretCreationDateTime.ToString("HH:mm:ss")
 
 
                $secretLastUpdatedateDateTime = $secret.Updated
 
                #$secretText = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -AsPlainText
 
 
 
                $result += [PSCustomObject]@{
                    SubscriptionName = $subscriptionName
                    ResourceGroupName = $resourceGroupName
                    KeyVaultName = $keyVaultName
                    KeyVaultLocation = $keyVaultLocation
                    ObjectType = $type
                    ObjectName = $secretName
                    ObjectID = $secretId
                    Status = $secretEnabled
                    CreationDate = $secretCreationDate
                    ExpirationDate = $secretExpirationDate
                    LastUpdatedateDateTime = $secretLastUpdatedateDateTime                    
                }
 
            }
 
        }
 
        foreach($certificate in $certificates){
 
            $type = "Certificate"
 
            $certificateName = $certificate.Name
            $certificateId = $certificate.Id
            $certificateEnabled = $certificate.Enabled
 
            $certificateExpirationDateTime = $certificate.Expires
 
            if ($null -ne $certificateExpirationDateTime){
 
                # echo $certificateExpirationDateTime
                $certificateExpirationDate = $certificateExpirationDateTime.ToString("dd/MM/yyyy")
                # $certificateExpirationTime = $certificateExpirationDateTime.ToString("HH:mm:ss")
 
            }else {
 
                $certificateExpirationDate = "No expiration"
 
            }
 
 
            $certificateCreationDateTime = $certificate.Created
            $certificateCreationDate = $certificateCreationDateTime.ToString("dd/MM/yyyy")
            # $certificateCreationTime = $certificateCreationDateTime.ToString("HH:mm:ss")
 
            $certificateLastUpdateDateTime = $certificate.Updated
 
            $tempCertificateId = $certificateId.replace('/certificates/','/keys/')
 
            $modifiedCertificateIDs.Add($tempCertificateId) | Out-Null
 
            $result += [PSCustomObject]@{
                SubscriptionName = $subscriptionName
                ResourceGroupName = $resourceGroupName
                KeyVaultName = $keyVaultName
                KeyVaultLocation = $keyVaultLocation
                ObjectType = $type
                ObjectName = $certificateName
                ObjectID = $certificateId
                Status = $certificateEnabled
                CreationDate = $certificateCreationDate
                ExpirationDate = $certificateExpirationDate
                LastUpdatedateDateTime = $certificateLastUpdateDateTime                    
            }
 
        }
 
        foreach ($key in $keys){
 
            $match = $modifiedCertificateIDs.Contains($key.Id)
 
            if($match -eq $false){
 
                $type = "Key"
 
                $keyName = $key.Name
                $keyId = $key.Id
                $keyEnabled = $key.Enabled
 
 
                $keyExpirationDateTime = $key.Expires
 
                if ($null -ne $keyExpirationDateTime){
 
                    $keyExpirationDate = $keyExpirationDateTime.ToString("dd/MM/yyyy")
                    # $keyExpirationTime = $keyExpirationDateTime.ToString("HH:mm:ss")
 
                }else{
 
                    $keyExpirationDate = "No expiration"
 
                }
 
 
                $keyCreationDateTime = $key.Created
                $keyCreationDate = $keyCreationDateTime.ToString("dd/MM/yyyy")
                # $keyCreationTime = $keyCreationDateTime.ToString("HH:mm:ss")
 
 
                $keyLastUpdateDateTime = $key.Updated
                #$keyRecoveryLevel = $key.RecoveryLevel
 
                $result += [PSCustomObject]@{
                    SubscriptionName = $subscriptionName
                    ResourceGroupName = $resourceGroupName
                    KeyVaultName = $keyVaultName
                    KeyVaultLocation = $keyVaultLocation
                    ObjectType = $type
                    ObjectName = $keyName
                    ObjectID = $keyId
                    Status = $keyEnabled
                    CreationDate = $keyCreationDate
                    ExpirationDate = $keyExpirationDate
                    LastUpdatedateDateTime = $keyLastUpdateDateTime                    
                }
 
            } 
 
        }
 
        Write-Host ("Readed data from Key Vault: " + $keyVaultName)
 
    }
 
}
 
# Get the current date
$date = Get-Date -Format "yyyy-MM-dd"
 
# Set the output file name and path
$path = "./Key Vaults_" + $date + ".csv"
 
# Write the result in the output file
$result | Export-Csv -Path $path -NoTypeInformation -Delimiter ';'