$header = "Ip Group Name; Location; Subscription Name; Resource Group Name;Ip Addresses"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $ipGroups =  Get-AzIpGroup

    foreach ($ipGroup in $ipGroups) {

        $currentTuple = ""

        $ipGroupName = $ipGroup.Name
        $ipGroupLocation = $ipGroup.Location
        $ipGroupResourceGroupName = $ipGroup.ResourceGroupName
        $ipAddresses = $ipGroup.IpAddresses 

        $currentTuple = "`n" +
            $ipGroupName + "; "+
            $ipGroupLocation + "; "+
            $subscriptionName + "; "+
            $ipGroupResourceGroupName + "; "+
            $ipAddresses

        $resultSet = $resultSet + $currentTuple

    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./IpGroups_" + $date + ".csv"
$result | Out-File -FilePath $path