#Trulite server template for 2 interfaces.
#Log in
Login-AzureRmAccount
#select our subscription
Get-AzureRMSubscription | Sort SubscriptionName | Select SubscriptionName
$subscr="Azure in Open"
Select-AzurermSubscription -SubscriptionName $subscr
#
$vmBaseName = "changeme"
$vmName="$vmBaseName"
$pubName="MicrosoftWindowsServer"
$offerName="WindowsServer"
$skuName="2012-R2-Datacenter"
$vmSize="Standard_D2_v2"
$rgName=‘Trulite_Hybrid’
$locName="EastUS"
$vm=New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$saName="trustorage01"
$vnetName="tru-hybrid-net01"
$subnetIndex0=0
$subnetIndex1=1
$nicName1="$vmBaseName.nic1"
$nicName2="$vmBaseName.nic2"
$staticIP1="10.33.1.x"
$staticIP2="10.33.2.x"
$nic1 = New-AzureRmNetworkInterface -Name $nicName1 -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PrivateIpAddress $staticIP1
$nic2 = New-AzureRmNetworkInterface -Name $nicName2 -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[1].Id -PrivateIpAddress $staticIP2
$cred=Get-Credential -Message "Type the name and password of the local administrator account."
$vm=Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"
$vm=Add-AzureRmVMNetworkInterface -VM $vm -Id $nic1.id
$vm=Add-AzureRmVMNetworkInterface -VM $vm -Id $nic2.id
$diskName="$vmbasename.disk1"
$storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $saName
$osDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName  + ".vhd"
$vm=Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
$vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true
New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm
