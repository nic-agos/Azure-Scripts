$header = "Route Table Name; Location; Subscription Name; Resource Group Name; BGP Propagation; Subnets; Route Name; Address Prefix; Next Hop Type; Next Hop Ip Address; Provisioning State"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $routeTables = Get-AzRouteTable

    foreach ($table in $routeTables){

        $tableName = $table.Name
        $tableLocation = $table.Location
        $resourceGroupName = $table.ResourceGroupName

        [bool] $bgpDisablePropagation = $table.DisableBgpRoutePropagation
        $bgpPropagation = -not $bgpDisablePropagation

        $subnetIds = $table.Subnets.Id
        $subnetNames = ""
        
        foreach ($id in $subnetIds){

            $subnetNameTemp = $id.Substring($id.LastIndexOf('/') + 1)

            $start = $id.indexOf('virtualNetworks/') + 16
            $end = $id.indexOf('subnets/')
            $vnetNameTemp = $id.Substring($start, ($end - $start)-1)

            $subnetName = $vnetNameTemp + "/" + $subnetNameTemp + " "

            $subnetNames = $subnetNames + $subnetName

        }
        

        foreach($route in $table.Routes){

            $currentTuple = ""

            $routeName = $route.Name
            $routeAddressPrefix = $route.AddressPrefix
            $routeNextHopType = $route.NextHopType
            $routeNextHopIpAddress = $route.NextHopIpAddress
            $routeProvisioningState = $route.ProvisioningState

            $currentTuple = "`n" + 
                $tableName + "; "+
                $tableLocation + "; "+
                $subscriptionName + "; "+
                $resourceGroupName + "; "+
                $bgpPropagation + "; "+
                $subnetNames + "; "+
                $routeName + "; "+
                $routeAddressPrefix + "; "+
                $routeNextHopType + "; "+
                $routeNextHopIpAddress + "; "+
                $routeProvisioningState

            $resultSet = $resultSet + $currentTuple

        }

    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./RouteTables_" + $date + ".csv"
$result | Out-File -FilePath $path

