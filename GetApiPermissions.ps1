# Set the header for the CSV file
$header = "Application Display Name;Application (client) ID;Creation DateTime;Object ID;API Display Name;API ID;Permission; Permission Description"

# Set the result sets as empty
$resultSet = ""

$adApplications = Get-AzADApplication

foreach($adApplication in $adApplications){

    $appCreatedDateTime = $adApplication.CreatedDateTime

    $currentTuple = ""
    
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
            
            # Get the permission ID
            $permissionId = $resource.ResourceAccess.Id

            #Get the permission type
            $permissionType = $resource.ResourceAccess.Type

            # Get the API object
            $api = Get-AzADServicePrincipal -ApplicationId $resourceApiId
            
            # Get the API Display Name
            $apiDisplayName = $api.AppDisplayName
            
            # Get the API App Roles
            $appRoles = $api.AppRole 

            # Get the API Oauth2 Permissions
            $oauth2PermissionScope = $api.Oauth2PermissionScope

            if($permissionType -eq "Scope"){
                
                # Get the permission object
                $permissionInScope = $oauth2PermissionScope | Where-Object {$_.id -eq $permissionId}

                # Get the permission name
                $permissionInScopeValue = $permissionInScope.Value

                # Get the permission description
                $permissionInScopeAdminConsentDescription = $permissionInScope.AdminConsentDescription

                $currentTuple = "`n" + 
                    $appDisplayName + ";" + 
                    $appId + ";" +
                    $appCreatedDateTime + ";" +
                    $objectId + ";" +
                    $apiDisplayName + ";" +
                    $resourceApiId + ";" +
                    $permissionInScopeValue + ";" +
                    $permissionInScopeAdminConsentDescription
                
            }

            if ($permissionType -eq "Role"){

                # Get the permission object
                $permissionInRole = $appRoles | Where-Object {$_.id -eq $permissionId}

                # Get the permission name
                $permissionInRoleValue = $permissionInRole.Value

                # Get the permission description
                $permissionInRoleAdminConsentDescription = $permissionInRole.AdminConsentDescription

                $currentTuple = "`n" + 
                    $appDisplayName + ";" + 
                    $appId + ";" +
                    $appCreatedDateTime + ";" +
                    $objectId + ";" +
                    $apiDisplayName + ";" +
                    $resourceApiId + ";" +
                    $permissionInRoleValue + ";" +
                    $permissionInRoleAdminConsentDescription

            }
        
            $resultSet = $resultSet + $currentTuple

        }
        
    }
    
}

# Get the current date
$date = Get-Date -Format "yyyy-MM-dd"

# Concat the header row with the result set rows
$result = ($header + $resultSet)

# Set the output file name and path
$path = "./API Permissions_" + $date + ".csv"

# Write the result in the output file
$result | Out-File -FilePath $path