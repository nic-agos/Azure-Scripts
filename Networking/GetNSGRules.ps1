$header = "NSG Name; NSG Location; Subscription Name; Resource Group Name; Subnets; Network Interfaces; Direction; Priority; Rule Name; Source Port Range; Protocol; Source Address Prefix; Destination Address Prefix; Destination Port Range; Action"

$resultSet = ""

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions){

    $subscriptionName = $sub.Name
    Select-AzSubscription -SubscriptionName $subscriptionName

    $nsgList = Get-AzNetworkSecurityGroup

    foreach ($nsg in $nsgList){

        $nsgName = $nsg.Name
        $nsgResourceGroupName = $nsg.ResourceGroupName
        $nsgLocation = $nsg.Location

        $subnetIds = $nsg.Subnets.Id
        $subnetNames = ""

        foreach ($id in $subnetIds){

            $subnetNameTemp = $id.Substring($id.LastIndexOf('/') + 1)

            $start = $id.indexOf('virtualNetworks/') + 16
            $end = $id.indexOf('subnets/')
            $vnetNameTemp = $id.Substring($start, ($end - $start)-1)

            $subnetName = $vnetNameTemp + "/" + $subnetNameTemp + " "

            $subnetNames = $subnetNames + $subnetName

        }

        $NetworkInterfaceIds = $nsg.NetworkInterfaces.Id
        $nicNames = ""

        foreach ($id in $NetworkInterfaceIds){

            $nicNameTemp = $id.Substring($id.LastIndexOf('/') + 1)

            $nicNames = $nicNames + $nicNameTemp + " "

        }

        $nsgSecurityRules = $nsg.SecurityRules
        
        foreach ($securityRule in $nsgSecurityRules){

            $currentTuple = ""

            $securityRuleName = $securityRule.Name
            $securityRuleDirection = $securityRule.Direction
            $securityRulePriority = $securityRule.Priority

            $securityRuleSourcePortRange = $securityRule.SourcePortRange
            $securityRuleProtocol = $securityRule.Protocol
            $securityRuleSourceAddressPrefix = $securityRule.SourceAddressPrefix

            $securityRuleDestinationAddressPrefix = $securityRule.DestinationAddressPrefix
            $securityRuleDestinationPortRange = $securityRule.DestinationPortRange

            $securityRuleAction = $securityRule.Access
            
            $currentTuple = "`n" +
                $nsgName + "; "+
                $nsgLocation + "; "+
                $subscriptionName + "; "+
                $nsgResourceGroupName + "; "+
                $subnetNames + "; "+
                $nicNames + "; "+
                $securityRuleDirection + "; "+
                $securityRulePriority + "; "+ 
                $securityRuleName + "; "+ 
                $securityRuleSourcePortRange + "; "+ 
                $securityRuleProtocol + "; "+ 
                $securityRuleSourceAddressPrefix + "; "+
                $securityRuleDestinationAddressPrefix + "; "+
                $securityRuleDestinationPortRange + "; "+
                $securityRuleAction

            $resultSet = $resultSet + $currentTuple

        }

        $nsgDefaultSecurityRules = $nsg.DefaultSecurityRules

        foreach ($defaultSecurityRule in $nsgDefaultSecurityRules){

            $currentTuple = ""

            $defaultSecurityRuleName = $defaultSecurityRule.Name
            $defaultSecurityRuleDirection = $defaultSecurityRule.Direction
            $defaultSecurityRulePriority = $defaultSecurityRule.Priority

            $defaultSecurityRuleSourcePortRange = $defaultSecurityRule.SourcePortRange
            $defaultSecurityRuleProtocol = $defaultSecurityRule.Protocol
            $defaultSecurityRuleSourceAddressPrefix = $defaultSecurityRule.SourceAddressPrefix

            $defaultSecurityRuleDestinationAddressPrefix = $defaultSecurityRule.DestinationAddressPrefix
            $defaultSecurityRuleDestinationPortRange = $defaultSecurityRule.DestinationPortRange

            $defaultSecurityRuleAction = $defaultSecurityRule.Access

            $currentTuple = "`n" +
                $nsgName + "; "+
                $nsgLocation + "; "+
                $subscriptionName + "; "+
                $nsgResourceGroupName + "; "+
                $subnetNames + "; "+
                $nicNames + "; "+
                $defaultSecurityRuleDirection + "; "+
                $defaultSecurityRulePriority + "; "+
                $defaultSecurityRuleName + "; "+
                $defaultSecurityRuleSourcePortRange + "; "+
                $defaultSecurityRuleProtocol + "; "+
                $defaultSecurityRuleSourceAddressPrefix + "; "+
                $defaultSecurityRuleDestinationAddressPrefix + "; "+
                $defaultSecurityRuleDestinationPortRange + "; "+
                $defaultSecurityRuleAction
            
            $resultSet = $resultSet + $currentTuple
  
        }
    
    }

}

$date = Get-Date -Format "dd-MM-yyyy"

$result = ($header + $resultSet)
$path = "./NSGs_" + $date + ".csv"
$result | Out-File -FilePath $path