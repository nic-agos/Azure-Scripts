# Variables
 
$firewallName = "az-fw-01"
 
$resourceGroup = "rg-test-01"

# Subscription ID
$subscriptionId = "281c6209-21b4-4388-90d0-66859c58193d"
 
# Authenticate to Azure
Connect-AzAccount

# Select Subscription
Select-AzSubscription $subscriptionId

# Get firewall informations
$firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $resourceGroup

# Get DNAT rule Collection
$dnatRules = $firewall.NatRuleCollections

# Get network rule Collection
$networkRules = $firewall.NetworkRuleCollections

# Get application rule Collection
$appRules = $firewall.ApplicationRuleCollections 


#App Rules
$headerApp = "Rule Collection Name; Priority; Action; Rule name; SourceAddresses; TargetFqdns; FqdnTags; Protocol:Port; SourceIpGroups"
$resultSetApp = ""

foreach($ne in $appRules){

    $appRuleCollectionName = $ne.Name 
    $appRuleCollectionPriority = $ne.Priority 
    $appRuleCollectionAction = $ne.Action.Type
    
    foreach($n in $ne.Rules) {

        $currentTupleApp = ""
        
        $appRuleName = $n.name
        $appRuleSourceAddresses = $n.SourceAddresses        
        $appRuleTargetFqdns = $n.TargetFqdns
        $appRuleFqdnTags = $n.FqdnTags
        $appRuleProtocols = $n.Protocols
        $protocolTMP = ""
        foreach ($p in $appRuleProtocols) {
            $protocolTMP = $protocolTMP + $p.ProtocolType + ":" + $p.Port + " "
        }

        $appRuleSourceIpGroupsTemp = $n.SourceIpGroups
        $appRuleSourceIpGroups = ""

        foreach ($ipGroup in $appRuleSourceIpGroupsTemp){

            $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
            $appRuleSourceIpGroups = $appRuleSourceIpGroups + ($ipGroupName + " ")

        }

        $currentTupleApp = "`n" + 
            $appRuleCollectionName + "; "+ 
            $appRuleCollectionPriority + "; " + 
            $appRuleCollectionAction + "; " + 
            $appRuleName + "; " + 
            $appRuleSourceAddresses + "; " + 
            $appRuleTargetFqdns + "; " + 
            $appRuleFqdnTags + "; " + 
            $protocolTMP + "; " + 
            $appRuleSourceIpGroups
        
            $resultSetApp = $resultSetApp + $currentTupleApp

    }

}


#DNAT Rules
$headerDnat = "Rule Collection Name; Priority; Action; Rule name; Protocols; SourceAddresses; SourceIpGroups; DestinationAddresses; DestinationPorts; TranslatedAddress; TranslatedFqdn; TranslatedPort"
$resultSetDnat = ""

foreach($ne in $dnatRules){

    $dnatRuleCollectionName = $ne.Name 
    $dnatRuleCollectionPriority = $ne.Priority 
    $dnatRuleCollectionAction = $ne.Action.Type
    
    
    foreach($n in $ne.Rules) {
        
        $currentTupleDnat = ""

        $dnatRuleName = $n.name
        $dnatRuleProtocols = $n.Protocols
        $dnatRuleSourceAddresses = $n.SourceAddresses      
        
        $dnatRuleSourceIpGroupsTemp = $n.SourceIpGroups
        $dnatRuleSourceIpGroups = ""

        foreach ($ipGroup in $dnatRuleSourceIpGroupsTemp){

            $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
            $dnatRuleSourceIpGroups = $dnatRuleSourceIpGroups + ($ipGroupName + " ")

        }

        $dnatRuleDestinationAddresses = $n.DestinationAddresses
        $dnatRuleDestinationPorts = $n.DestinationPorts
        $dnatRuleTranslatedAddress = $n.TranslatedAddress
        $dnatRuleTranslatedFqdn = $n.TranslatedFqdn
        $dnatRuleTranslatedPort = $n.TranslatedPort
        
        
        $currentTupleDnat = "`n" + 
            $dnatRuleCollectionName + "; "+ 
            $dnatRuleCollectionPriority + "; " + 
            $dnatRuleCollectionAction + "; " + 
            $dnatRuleName + "; " + 
            $dnatRuleProtocols + "; " + 
            $dnatRuleSourceAddresses + "; " + 
            $dnatRuleSourceIpGroups + "; " + 
            $dnatRuleDestinationAddresses + "; " + 
            $dnatRuleDestinationPorts + "; " + 
            $dnatRuleTranslatedAddress + "; " + 
            $dnatRuleTranslatedFqdn + "; " + 
            $dnatRuleTranslatedPort

        $resultSetDnat = $resultSetDnat + $currentTupleDnat
        
    }
} 

#Network Rules
$headerNet = "Rule Collection Name; Priority; Action; Rule name; Protocols; SourceAddresses; DestinationAddresses; SourceIpGroups; DestinationIpGroups; DestinationFqdns; DestinationPorts"
$resultSetNet = ""

foreach($ne in $networkRules){

    $networkRuleCollectionName = $ne.Name 
    $networkRuleCollectionPriority = $ne.Priority 
    $networkRuleCollectionAction = $ne.Action.Type
    
    
    foreach($n in $ne.Rules) {

        $currentTupleNet = ""
        $networkRuleName = $n.name
        $networkRuleProtocols = $n.Protocols
        $networkRuleSourceAddresses = $n.SourceAddresses
        $networkRuleDestinationAddresses = $n.DestinationAddresses

        $networkRuleSourceIpGroupsTemp = $n.SourceIpGroups
        $networkRuleSourceIpGroups = ""

        foreach ($ipGroup in $networkRuleSourceIpGroupsTemp){

            $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
            $networkRuleSourceIpGroups =  $networkRuleSourceIpGroups + ($ipGroupName + " ")

        }


        $networkRuleDestinationIpGroupsTemp = $n.DestinationIpGroups
        $networkRuleDestinationIpGroups = ""

        foreach ($ipGroup in $networkRuleDestinationIpGroupsTemp){

            $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
            $networkRuleDestinationIpGroups =  $networkRuleDestinationIpGroups + ($ipGroupName + " ")

        }

       
        $networkRuleDestinationFqdns = $n.DestinationFqdns
        $networkRuleDestinationPorts = $n.DestinationPorts


        $currentTupleNet = "`n" + 
            $networkRuleCollectionName + "; "+ 
            $networkRuleCollectionPriority + "; " + 
            $networkRuleCollectionAction + "; " + 
            $networkRuleName + "; " + 
            $networkRuleProtocols + "; " + 
            $networkRuleSourceAddresses + "; " + 
            $networkRuleDestinationAddresses + "; " + 
            $networkRuleSourceIpGroups + "; " + 
            $networkRuleDestinationIpGroups + "; " + 
            $networkRuleDestinationFqdns + "; " + 
            $networkRuleDestinationPorts
        
        $resultSetNet = $resultSetNet + $currentTupleNet

    }
}

$date = Get-Date -Format "dd-MM-yyyy"

$appResult = ($headerApp + $resultSetApp)
$appRulePath = "./" +  $firewallName + "_APP_" + $date + ".csv"
$appResult | Out-File -FilePath $appRulePath


$dnatResult = ($headerDnat + $resultSetDnat) 
$dnatRulePath = "./" +  $firewallName + "_DNAT_" + $date + ".csv"
$dnatResult | Out-File -FilePath $dnatRulePath

$netResult = ($headerNet + $resultSetNet) 
$netRulePath = "./" +  $firewallName + "_NET_" + $date + ".csv"
$netResult | Out-File -FilePath $netRulePath