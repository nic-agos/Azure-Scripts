$adApplications = Get-AzADApplication

foreach($adApplication in $adApplications){
    
    $appId = $adApplication.Id

    $app = Get-AzADApplication -ObjectId $appId

    $requiredResourceAccess = $app.requiredResourceAccess

    foreach ($resourceAccess in $requiredResourceAccess){

        foreach($resource in $resourceAccess){

            $resourceAppId = $resource.ResourceAppId
            $permissionId = $resource.ResourceAccess.Id
            $permissionType = $resource.ResourceAccess.Type

            $servicePrincipal = Get-AzADServicePrincipal -ApplicationId $resourceAppId
            
            $servicePrincipalDisplayName = $servicePrincipal.AppDisplayName
            
            $appRoles = $servicePrincipal.AppRole 
            $oauth2PermissionScope = $servicePrincipal.Oauth2PermissionScope

            if($permissionType -eq "Scope"){

                $permissionInScope = $oauth2PermissionScope | Where-Object {$_.id -eq $permissionId}
                $permissionInScopeValue = $permissionInScope.Value
                echo $permissionInScopeValue
            }

            if ($permissionType -eq "Role"){
                $permissionInRole = $appRoles | Where-Object {$_.id -eq $permissionId}
                $permissionInRoleValue = $permissionInScope.Value
                echo $permissionInRoleValue
            }
        
        }
        
    }
    
}