$result = @()
 
$adApplications = Get-AzADApplication
 
foreach($adApplication in $adApplications){
 
    $appCreationDateTime = $adApplication.CreatedDateTime
 
    $appCreationDate = $appCreationDateTime.ToString("dd/MM/yyyy")
    $appCreationTime = $appCreationDateTime.ToString("HH:mm:ss")
 
    # Get the Application (client) Display Name
    $appDisplayName = $adApplication.DisplayName
 
    # Get the Application (client) ID
    $appId = $adApplication.AppId
 
    # Get the object ID
    $objectId = $adApplication.Id
 
    $app = Get-AzADApplication -ObjectId $objectId
 
    $requiredResourceAccess = $app.requiredResourceAccess
 
    foreach ($resourceAccess in $requiredResourceAccess){
 
        foreach($resource in $resourceAccess){
 
            # Get the API ID
            $resourceApiId = $resource.ResourceAppId
 
            # Get the API object
            $api = Get-AzADServicePrincipal -ApplicationId $resourceApiId
 
            # Get the API Display Name
            $apiDisplayName = $api.AppDisplayName
 
 
            foreach($permission in $resource.ResourceAccess){
 
                # Get the permission ID
                $permissionId = $permission.Id
 
                #Get the permission type
                $permissionType = $permission.Type
 
                # Get the API Oauth2 Permissions
                $oauth2PermissionScope = $api.Oauth2PermissionScope
 
                # Get the API App Roles
                $appRoles = $api.AppRole 
 
 
                if($permissionType -eq "Scope"){
 
                    # Get the permission object
                    $permissionInScope = $oauth2PermissionScope | Where-Object {$_.id -eq $permissionId}
 
                    # Get the permission name
                    $permissionInScopeValue = $permissionInScope.Value
 
                    # Get the permission description
                    $permissionInScopeDescription = $permissionInScope.AdminConsentDescription
 
 
                    $result += [PSCustomObject]@{
                        ApplicationName = $appDisplayName
                        ApplicationClientId = $appId
                        ObjectID = $objectId
                        CreationDate = $appCreationDate
                        CreationTime = $appCreationTime
                        ApiName = $apiDisplayName
                        ApiID = $resourceApiId
                        Permission = $permissionInScopeValue
                        PermissionDescription = $permissionInScopeDescription
                    }
 
                }
 
                if ($permissionType -eq "Role"){
 
                    # Get the permission object
                    $permissionInRole = $appRoles | Where-Object {$_.id -eq $permissionId}
 
                    # Get the permission name
                    $permissionInRoleValue = $permissionInRole.Value
 
                    # Get the permission description
                    $permissionInRoleDescription = $permissionInRole.Description
 
                    $result += [PSCustomObject]@{
                        ApplicationName = $appDisplayName
                        ApplicationClientId = $appId
                        CreationDate = $appCreationDate
                        CreationTime = $appCreationTime
                        ObjectID = $objectId
                        ApiName = $apiDisplayName
                        ApiID = $resourceApiId
                        Permission = $permissionInRoleValue
                        PermissionDescription = $permissionInRoleDescription
                    }
 
                }
 
            }     
 
        }
 
    }
 
    Write-Host ("Readed data for application: " + $appDisplayName)
 
}
 
# Get the current date
$date = Get-Date -Format "yyyy-MM-dd"
 
# Set the output file name and path
$path = "./API Permissions_" + $date + ".csv"
 
# Write the result in the output file
$result | Export-Csv -Path $path -NoTypeInformation -Delimiter ';'