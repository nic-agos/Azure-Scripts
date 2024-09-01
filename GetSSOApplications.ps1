$result = @()
 
$servicePrincipals = Get-AzADServicePrincipal
 
foreach ($servicePrincipal in $servicePrincipals){
 
    # echo $servicePrincipal | fl
 
    $displayName = $servicePrincipal.DisplayName
 
    $preferredSingleSignOnMode = $servicePrincipal.PreferredSingleSignOnMode
 
    $applicationId = $servicePrincipal.AppId
 
    $servicePrincipalId = $servicePrincipal.Id
 
    $ssoStatus = ""
    $ssoMethod = ""
 
    if($null -ne $preferredSingleSignOnMode){
 
        $ssoStatus = "Enabled"
        $ssoMethod = $preferredSingleSignOnMode
 
    }else{
 
        $ssoStatus = "Not enabled"
        $ssoMethod = "Not available"
 
    }
 
    $result += [PSCustomObject]@{
        ApplicationName = $displayName
        ApplicationId = $applicationId
        ObjectID = $servicePrincipalId
        ssoStatus = $ssoStatus
        ssoMethod = $ssoMethod
    }
 
 
}
 
# Get the current date
$date = Get-Date -Format "yyyy-MM-dd"
 
# Set the output file name and path
$path = "./SSO Applications_" + $date + ".csv"
 
$result | Export-Csv -Path $path -NoTypeInformation -Delimiter ';'