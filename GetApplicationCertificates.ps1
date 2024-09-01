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
 
    $keyCredentials = $adApplication.KeyCredentials
 
    foreach ($certificate in $keyCredentials){
 
        $certificateThumbprint = $certificate.customKeyIdentifier
        $certificateDisplayName = $certificate.displayName
 
        $certificateEndDateTime = $certificate.endDateTime
        $certificateEndDate = $certificateEndDateTime.ToString("dd/MM/yyyy")
        # $certificateEndTime = $certificateEndtDateTime.ToString("HH:mm:ss")
 
        $certificateStartDateTime = $certificate.startDateTime
        $certificateStartDate = $certificateStartDateTime.ToString("dd/MM/yyyy")
        # $certificateStartTime = $certificateStartDateTime.ToString("HH:mm:ss")
 
        $certificateID = $certificate.keyId
        $certificateType = $certificate.type
 
        $result += [PSCustomObject]@{
            ApplicationName = $appDisplayName
            ApplicationClientId = $appId
            ObjectID = $objectId
            CertificateName = $certificateDisplayName
            CertificateID = $certificateID
            CertificateThumbprint = $certificateThumbprint
            CertificateType = $certificateType
            CreationDate = $certificateStartDate
            ExpirationDate = $certificateEndDate
        }
 
    }
 
    Write-Host ("Readed certificates for application: " + $appDisplayName)
 
}
 
# Set the output file name and path
$path = "./Aplication Certificates_" + $date + ".csv"
 
# Write the result in the output file
$result | Export-Csv -Path $path -NoTypeInformation -Delimiter ';'