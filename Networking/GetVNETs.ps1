$header = "VNET Name; Location; Subscription Name; Resource Group Name; Address Space"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $virtualNewtorks = Get-AzVirtualNetwork
    
    foreach ($vnet in $virtualNewtorks){

        $currentTuple = ""

        $vnetName = $vnet.Name
        $vnetLocation = $vnet.Location
        $resourceGroupName = $vnet.ResourceGroupName
    
        $vnetAddressSpace = $vnet.AddressSpace.AddressPrefixes
        
        $vnetPeerings = 

            $currentTuple = "`n" +
                $vnetName + "; "+
                $vnetLocation + "; "+
                $subscriptionName + "; "+
                $resourceGroupName + "; "+
                $vnetAddressSpace

            $resultSet = $resultSet + $currentTuple
    
    }
}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./VNETs_" + $date + ".csv"
$result | Out-File -FilePath $path


