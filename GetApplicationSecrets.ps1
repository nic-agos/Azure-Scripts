$result = @()
 
# Get the current date
$date = Get-Date -Format "yyyy-MM-dd"
 
$adApplications = Get-AzADApplication
 
foreach($adApplication in $adApplications){
 
    # Get the Application (client) Display Name
    $appDisplayName = $adApplication.DisplayName
 
    # Get the Application (client) ID
    $appId = $adApplication.AppId
 
    # Get the object ID
    $objectId = $adApplication.Id
 
    $passwordCredentials = $adApplication.PasswordCredentials
 
 
    foreach ($secret in $passwordCredentials){
 
        $secretDisplayName = $secret.displayName
 
        $secretCreationDateTime = $secret.startDateTime
        $secretCreationDate = $secretCreationDateTime.ToString("dd/MM/yyyy")
        # $secretCreationTime = $secretCreationDateTime.ToString("HH:mm:ss")
 
        $secretExpirationDateTime = $secret.endDateTime
        $secretExpirationDate = $secretExpirationDateTime.ToString("dd/MM/yyyy")
        # $secretExpirationTime = $secretExpirationDateTime.ToString("HH:mm:ss")
 
        $secretHint = $secret.hint
        $secretKeyId = $secret.keyId
 
            $result += [PSCustomObject]@{
                ApplicationName = $appDisplayName
                ApplicationClientId = $appId
                ObjectID = $objectId
                SecretName = $secretDisplayName
                SecretHint = $secretHint
                SecretID = $secretKeyId
                CreationDate = $secretCreationDate
                ExpirationDate = $secretExpirationDate
            }
 
    }
 
    Write-Host ("Readed secrets for application: " + $appDisplayName)
 
}
 
 
# Set the output file name and path
$path = "./Aplication Secrets_" + $date + ".csv"
 
# Write the result in the output file
$result | Export-Csv -Path $path -NoTypeInformation -Delimiter ';'