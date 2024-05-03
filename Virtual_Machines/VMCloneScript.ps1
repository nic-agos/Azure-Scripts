## Questo script clona la VM "bul-dcs-be02wp" (BUL-HUB-PLT\bul-rg-we-dcs-p)(bul-vnet-we-sha-p/sub-sha-ad)
## generando la VM di destinazione "bul-we-sbx-addc-02" (BUL-HUB-PLT\bul-rg-we-hub-sbx-s)(bul-vnet-we-hub-sbx-s/sub-sbx-addc)
## Genero anche la NIC per assegnare l'ip statico e cancello la VM se già esistente

# Subscription dove la VM dove andrò a creare Snapshot, Disk e VM (BUL-HUB-PLT)  
$DestinationSubscription = "6dbd11e6-0409-4acb-a174-836394b8d653"
$DestinationVM_ResourceGroup = "rg-test-01"
$DestinationVM_Name = "vm-test-dest"
$DestinationVM_DATADISK_Name = "datadisk-test-dest"

# Imposto la subscription di destinazione
az account set -s $DestinationSubscription

# Se la VM di destinazione c'è già, allora la elimino (vengono rimossi in automatico anche il disco OS e la NIC perchè la VM è stata creata con apposita opzione - il data disk lo elimino esplicitamente causa bug)

if ( $(az vm list --resource-group $DestinationVM_ResourceGroup --query "[?name=='$DestinationVM_Name'] | length(@)")-gt 0 ) {
    Write-Host ("VM Presente => La elimino")
    az vm delete -g $DestinationVM_ResourceGroup -n $DestinationVM_Name --yes
    az disk delete -g $DestinationVM_ResourceGroup -n $DestinationVM_DATADISK_Name --yes
}

# Disco della VM da migrare
$SourceVM_OS_DISK = "/subscriptions/6dbd11e6-0409-4acb-a174-836394b8d653/resourceGroups/test/providers/Microsoft.Compute/disks/vm-test-01_disk1_ddbf8cbc42ee4127bba206c8621d7b6c"

# Creo lo snapshot
$SnapshotName = "snap-test-01"
az snapshot create -g $DestinationVM_ResourceGroup -n $SnapshotName --incremental false -l "westeurope" --source $SourceVM_OS_DISK --sku "Standard_ZRS"

# Creo il disco dallo snapshot (può tornare utile az disk show --ids $SourceVM_DISK --query sku.name ) e poi cancello lo snapshot
# [--sku {PremiumV2_LRS, Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS, UltraSSD_LRS}]
$DestinationVM_DISK_Name = "osdisk-test-dest"
$DestinationVM_DISK_SKU = "Premium_ZRS"
az disk create -g $DestinationVM_ResourceGroup -n $DestinationVM_DISK_Name --sku $DestinationVM_DISK_SKU --source $SnapshotName
az snapshot delete -g $DestinationVM_ResourceGroup -n $SnapshotName

# Creo la NIC per VM con l'ip statico
$DestinationVM_Vnet = "vnet-test-01"
$DestinationVM_Subnet ="subnet-test-01"
$DestinationVM_NIC_Name = "nic-test-dest"
$DestinationVM_IpAddress ="10.0.1.4"
az network nic create -g $DestinationVM_ResourceGroup -n $DestinationVM_NIC_Name --vnet-name $DestinationVM_Vnet --subnet $DestinationVM_Subnet --private-ip-address $DestinationVM_IpAddress

# Creo la VM con il disco OS appena creato (Per usare hybrid benefit aggiungere --license-type "Windows_Server")
$OS_Type = "Windows"
$DestinationVM_Size = "Standard_B1s"
az vm create -g $DestinationVM_ResourceGroup -n $DestinationVM_Name --attach-os-disk $DestinationVM_DISK_Name --os-type $OS_Type --public-ip-address '""' --nsg '""' --nics $DestinationVM_NIC_Name --size $DestinationVM_Size --os-disk-delete-option Delete --data-disk-delete-option Delete --nic-delete-option Delete --tags "Creation Date=$(get-date)"

# Creo lo snapshot per il disco dati aggiuntivo della VM sorgente
$SourceVM_DATA_DISK = "/subscriptions/6dbd11e6-0409-4acb-a174-836394b8d653/resourceGroups/TEST/providers/Microsoft.Compute/disks/disk-test-02"
$DestinationVM_Snapshot_DATADISK_Name = "snap-datadisk-test-dest"
az snapshot create -g $DestinationVM_ResourceGroup -n $DestinationVM_Snapshot_DATADISK_Name --incremental false -l "westeurope" --source $SourceVM_DATA_DISK --sku "Standard_ZRS"
az disk create -g $DestinationVM_ResourceGroup --source $DestinationVM_Snapshot_DATADISK_Name --sku $DestinationVM_DISK_SKU -n $DestinationVM_DATADISK_Name
az vm disk attach -g $DestinationVM_ResourceGroup --vm-name $DestinationVM_Name --name $DestinationVM_DATADISK_Name --caching ReadWrite
az snapshot delete -g $DestinationVM_ResourceGroup -n $DestinationVM_Snapshot_DATADISK_Name

# Abilito il Boot Diagnostics
az vm boot-diagnostics enable -g $DestinationVM_ResourceGroup -n $DestinationVM_Name