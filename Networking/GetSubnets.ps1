$header = "VNET Name; VNET Location; Subscription Name; Resource Group Name; Subnet Name; Subnet Address Range; Subnet Route Table; Subnet NSG; Subnet Delegation; Subnet Service Endpoints; NAT Gateway;Free IPs;Used IPs"
 
$result = ""
$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $virtualNewtorks = Get-AzVirtualNetwork
    
    foreach ($vnet in $virtualNewtorks){

        $vnetName = $vnet.Name
        $vnetLocation = $vnet.Location
        $resourceGroupName = $vnet.ResourceGroupName
        
        $subnets = $vnet.Subnets
    
        foreach ($sub in $subnets){

            $currentTuple = ""

            $subnetName = $sub.Name
            $subnetAddressRange = $sub.AddressPrefix
            $subnetDelegation = $sub.Delegations.ServiceName
    
            $subnetRouteTableId = $sub.RouteTable.Id
            if ($null -ne $subnetRouteTableId) {
                $subnetRouteTable = $subnetRouteTableId.Substring($subnetRouteTableId.LastIndexOf('/') + 1)
            } else {
                $subnetRouteTable = ""
            }
    
            $subnetNetworkSecurityGroupId = $sub.NetworkSecurityGroup.Id
            if ($null -ne $subnetNetworkSecurityGroupId) {
                $subnetNetworkSecurityGroup = $subnetNetworkSecurityGroupId.Substring($subnetNetworkSecurityGroupId.LastIndexOf('/') + 1)
            } else {
                $subnetNetworkSecurityGroup = ""
            }
            
            $subnetServiceEndpoints = $sub.ServiceEndpoints
            $serviceEndpointNames = ""
            foreach ($serviceEndpoint in $subnetServiceEndpoints){

                $serviceEndpointTemp = $serviceEndpoint.Service
                $serviceEndpointNames = $serviceEndpointNames + $serviceEndpointTemp + " "

            }

            $subnetNatGatewayId = ""
            $subnetNatGatewayId = $sub.NatGateway.Id
 
 
            if($null -ne $subnetNatGatewayId){
 
                $subnetNatGatewayName = $subnetNatGatewayId.Substring($subnetNatGatewayId.LastIndexOf('/') + 1)
 
            }else{
 
                $subnetNatGatewayName = ""
            }
 
            $subnetMask = $sub.AddressPrefix.Split("/")[1]
 
            $subnetTotalIps = ([Math]::Pow(2, 32 - [int]$subnetMask)) - 5
 
            $subnetUsedIps = $sub.IpConfigurations.Count
 
            $subnetAvailableIps = $subnetTotalIps - $subnetUsedIps

            $currentTuple = "`n" +
                $vnetName + "; "+
                $vnetLocation + "; "+
                $subscriptionName + "; "+
                $resourceGroupName + "; "+
                $subnetName + "; "+
                $subnetAddressRange + "; "+
                $subnetRouteTable + "; "+
                $subnetNetworkSecurityGroup + "; "+
                $subnetDelegation + "; "+
                $serviceEndpointNames + "; "+
                $subnetNatGatewayName + "; "+
                $subnetAvailableIps + "; "+
                $subnetUsedIps

            $resultSet = $resultSet + $currentTuple

        }
    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./Subnets_" + $date + ".csv"
$result | Out-File -FilePath $path

Import-Csv $path -Delimiter ";" | Format-Table -AutoSize


