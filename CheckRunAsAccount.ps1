#Script per controllo scadenza certificati automation account
$sub= Get-AzSubscription #Lista subscription

foreach($s in $sub){
    Set-AzContext -SubscriptionName $sub.Name
    
    
    $resourceGroup = Get-AzResourceGroup #Lista Resource Group
    $hash = @{} #Dizionario di tutti i certificati in scadenza
    $actualDate = Get-Date
    foreach ($rg in $resourceGroup){


        $automation = Get-AzAutomationAccount -ResourceGroupName $rg.ResourceGroupName #Lista Automation Account

        if ($automation -ne $null){

            foreach ($a in $automation) {  
                
                #Preleva certificato
                $certificato = Get-AzAutomationCertificate -ResourceGroupName $a.ResourceGroupName -AutomationAccountName $a.AutomationAccountName
                if ($certificato -ne $null){
                    $date = $certificato.ExpiryTime.DateTime
                    $days = New-TimeSpan -Start $date -End $actualDate

                    #Controlla se il certificato scade entro massimo 30 Giorni
                    if ($days.Days -le 30){
                        $hash.Add($a.AutomationAccountName, $days.Days)
                        }
                    }
                }
            
        }
    }
}

#Crea CSV
$hash.GetEnumerator() |Select Name,Value |Export-Csv .\av8.csv