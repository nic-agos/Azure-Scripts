# Variables
 
$firewallPolicyName = "az-fwpolicy-01"
 
$resourceGroup = "az-rg-01"

# Subscription ID
$subscriptionId = "fec2c83c-7f6e-4664-b8f6-07c52ec157e9"

# Select the correct subscription
Select-AzSubscription $subscriptionId
 
# Get firewall informations
$firewallPolicy = Get-AzFirewallPolicy -Name $firewallPolicyName -ResourceGroupName $resourceGroup

# Set the header for the Network rules CSV file
$headerNetwork = "Rule Collection Group Name; Rule Collection Group Priority; Rule Collection Name; Rule Collection Priority; Rule Collection Action; Rule Name; Source Addresses; Source IP Groups; Protocols; DestinationPorts; Destination Addresses; Destination IP Groups; DestinationFQDNs"

# Set the header for the NAT rules CSV file
$headerNat = "Rule Collection Group Name; Rule Collection Group Priority; Rule Collection Name; Rule Collection Priority; Rule Collection Action; Rule Name; Source Addresses; Source IP Groups; Protocols; Destination Ports; Destination Addresses; Translated Address; Translated Fqdn; Translated Port"


# Set the header for the Application rules CSV file
$headerApplication = "Rule Collection Group Name; Rule Collection Group Priority; Rule Collection Name; Rule Collection Priority; Rule Collection Action; Rule Name; Source Addresses; Source IP Groups; Protocols; Target Fqdns; Fqdn Tags; Web Categories; Target Urls; Terminate TLS; Http Headers To Insert"

# Set the result sets as empty
$resultSetNat = ""
$resultSetNetwork = ""
$resultSetApplication = ""

# Get Rule Collection Groups
$RuleCollectionGroups = $firewallPolicy.RuleCollectionGroups

foreach ($collectionGroup in $RuleCollectionGroups.Id){

    $ruleCollectionGroupName = $collectionGroup.Substring($collectionGroup.LastIndexOf('/') + 1)

    #Get the Rule Collection Group from Firewall Policy
    $ruleCollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -Name $ruleCollectionGroupName -AzureFirewallPolicy $firewallPolicy

    $ruleCollectionGroupPriority = $RuleCollectionGroup.Properties.Priority

    foreach ($ruleCollection in $RuleCollectionGroup.Properties.RuleCollection) {

        foreach ($rule in $ruleCollection.rules) {

            if ($rule.RuleType -eq "NatRule"){

                $currentTupleNat = ""
    
                $ruleCollectionName = $ruleCollection.Name
                $ruleCollectionPriority = $ruleCollection.Priority
                $ruleCollectionAction = $ruleCollection.Action.Type

                $ruleName = $rule.Name
                $sourceAddresses = $rule.SourceAddresses

                $sourceIPGroupsTemp = $rule.SourceIPGroups
                $sourceIPGroups = ""

                foreach ($ipGroup in $sourceIPGroupsTemp){

                    $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
                    $sourceIPGroups = $sourceIPGroups + ($ipGroupName + " ")

                }
                
                $protocols = $rule.Protocols
                $destinationPorts = $rule.DestinationPorts
                $destinationAddresses = $rule.DestinationAddresses
                $translatedAddress = $rule.TranslatedAddress
                $translatedFqdn = $rule.TranslatedFqdn
                $translatedPort = $rule.TranslatedPort
    
                $currentTupleNat = "`n" + 
                    $ruleCollectionGroupName + "; "+
                    $ruleCollectionGroupPriority + "; "+
                    $ruleCollectionName + "; "+
                    $ruleCollectionPriority + "; "+
                    $ruleCollectionAction + "; "+
                    $ruleName + "; "+
                    $sourceAddresses + "; "+
                    $sourceIPGroups + "; "+
                    $protocols + "; "+
                    $destinationPorts + "; "+
                    $destinationAddresses + "; "+
                    $translatedAddress + "; "+
                    $translatedFqdn + "; "+
                    $translatedPort
    
                $resultSetNat = $resultSetNat + $currentTupleNat
                    
            }

            if ($rule.RuleType -eq "ApplicationRule"){

                $currentTupleApplication = ""
    
                $ruleCollectionName = $ruleCollection.Name
                $ruleCollectionPriority = $ruleCollection.Priority
                $ruleCollectionAction = $ruleCollection.Action.Type

                $ruleName = $rule.Name
                $sourceAddresses = $rule.SourceAddresses

                $sourceIPGroupsTemp = $rule.SourceIPGroups
                $sourceIPGroups = ""

                foreach ($ipGroup in $sourceIPGroupsTemp){

                    $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
                    $sourceIPGroups = $sourceIPGroups + ($ipGroupName + " ")

                }

                $protocols = $rule.Protocols
                $protocolTMP = ""
                foreach ($p in $protocols) {
                    $protocolTMP = $protocolTMP + $p.ProtocolType + ":" + $p.Port + " "
                }
                $targetFqdns = $rule.TargetFqdns
                $fqdnTags = $rule.fqdnTags
                $webCategories = $rule.WebCategories
                $targetUrls = $rule.targetUrls
                $terminateTLS = $rule.terminateTLS
                $httpHeadersToInsert = $rule.httpHeadersToInsert

                $currentTupleApplication = "`n" + 
                    $ruleCollectionGroupName + "; "+
                    $ruleCollectionGroupPriority + "; "+
                    $ruleCollectionName + "; "+
                    $ruleCollectionPriority + "; "+
                    $ruleCollectionAction + "; "+
                    $ruleName + "; "+
                    $sourceAddresses + "; "+
                    $sourceIPGroups + "; "+
                    $protocolTMP + "; "+
                    $targetFqdns + "; "+
                    $fqdnTags + "; "+
                    $webCategories + "; "+
                    $targetUrls + "; "+
                    $terminateTLS + "; "+
                    $httpHeadersToInsert

                $resultSetApplication = $resultSetApplication + $currentTupleApplication

            }

            if ($rule.RuleType -eq "NetworkRule"){

                $currentTupleNetwork = ""

                $ruleCollectionName = $ruleCollection.Name
                $ruleCollectionPriority = $ruleCollection.Priority
                $ruleCollectionAction = $ruleCollection.Action.Type

                $ruleName = $rule.Name
                $sourceAddresses = $rule.SourceAddresses

                $sourceIPGroupsTemp = $rule.SourceIPGroups
                $sourceIPGroups = ""

                foreach ($ipGroup in $sourceIPGroupsTemp){

                    $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
                    $sourceIPGroups = $sourceIPGroups + ($ipGroupName + " ")

                }

                $protocols = $rule.Protocols
                $destinationPorts = $rule.DestinationPorts
                $destinationAddresses = $rule.DestinationAddresses

                $destinationIPGroupsTemp = $rule.DestinationIPGroups
                $destinationIPGroups = ""

                foreach ($ipGroup in $destinationIPGroupsTemp){

                    $ipGroupName = $ipGroup.Substring($ipGroup.LastIndexOf('/') + 1)
                    $destinationIPGroups = $destinationIPGroups + ($ipGroupName + " ")

                }

                $destinationFQDNs = $rule.DestinationFQDNs

                $currentTupleNetwork = "`n" + 
                    $ruleCollectionGroupName + "; "+
                    $ruleCollectionGroupPriority + "; "+
                    $ruleCollectionName + "; "+
                    $ruleCollectionPriority + "; "+
                    $ruleCollectionAction + "; "+
                    $ruleName + "; "+
                    $sourceAddresses + "; "+
                    $sourceIPGroups + "; "+
                    $protocols + "; "+
                    $destinationPorts + "; "+
                    $destinationAddresses + "; "+
                    $destinationIPGroups + "; "+
                    $destinationFQDNs
    
                $resultSetNetwork = $resultSetNetwork + $currentTupleNetwork

            }
        } 
    }
}


$date = Get-Date -Format "dd-MM-yyyy"

$resultNetwork = ($headerNetwork + $resultSetNetwork)
$pathNetwork = "./" +  $firewallPolicyName + "_NET_" + $date + ".csv"
$resultNetwork | Out-File -FilePath $pathNetwork


$resultNat = ($headerNat + $resultSetNat)
$pathNat = "./" +  $firewallPolicyName + "_DNAT_" + $date + ".csv"
$resultNat | Out-File -FilePath $pathNat

$resultApplication = ($headerApplication + $resultSetApplication)
$pathApplication = "./" +  $firewallPolicyName + "_APP_" + $date + ".csv"
$resultApplication | Out-File -FilePath $pathApplication

