# Variables
$resourceGroupName = "myResourceGroup"
$location = "East US"
$publicIPName = "myPublicIP"
$loadBalancerName = "myLoadBalancer"
$backendAddressPoolName = "myBackendAddressPool"
$probeName = "myProbe"
$ruleName = "myRule"
$vmSize = "Standard_B2s"
$vmCount = 3
$gitRepoUrl = "https://github.com/kramit/CoffeeShopTemplate.git"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a public IP address
$publicIP = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $publicIPName -AllocationMethod Static -Sku Standard

# Create a load balancer
$frontendIPConfigName = "myFrontendConfig"
$frontendIPConfig = New-AzLoadBalancerFrontendIpConfig -Name $frontendIPConfigName -PublicIpAddress $publicIP
$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name $backendAddressPoolName
$probeConfig = New-AzLoadBalancerProbeConfig -Name $probeName -Protocol Http -Port 80 -RequestPath '/' -IntervalInSeconds 15 -ProbeCount 2
$ruleConfig = New-AzLoadBalancerRuleConfig -Name $ruleName -FrontendIpConfiguration $frontendIPConfig -BackendAddressPool $backendAddressPool -Probe $probeConfig -Protocol Tcp -FrontendPort 80 -BackendPort 80
$loadBalancer = New-AzLoadBalancer -ResourceGroupName $resourceGroupName -Name $loadBalancerName -Location $location -FrontendIpConfiguration $frontendIPConfig -BackendAddressPool $backendAddressPool -Probe $probeConfig -LoadBalancingRule $ruleConfig

# Create the virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "myVnet" -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name "mySubnet" -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

# Create network security group and rule
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "myNsg"
$nsgRule = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access "Allow"
$nsg = Add-AzNetworkSecurityGroupRuleConfig -NetworkSecurityGroup $nsg -SecurityRule $nsgRule
$nsg = Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

# Create virtual machines and attach them to the load balancer
for ($i = 1; $i -le $vmCount; $i++) {
    $vmName = "myVM$i"
    $nicName = "myNIC$i"
    $ipConfigName = "myIPConfig$i"

    # Create a network interface
    $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -NetworkSecurityGroupId $nsg.Id -LoadBalancerBackendAddressPoolId $loadBalancer.BackendAddressPools[0].Id

    # Create the virtual machine
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
    $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential (Get-Credential) -DisablePasswordAuthentication
    $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
    $vm = New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

    # Install Nginx and clone the Git repository
    $publicSettings = @{
        "commandToExecute" = "apt-get update && apt-get install -y nginx git && systemctl enable nginx && systemctl start nginx && cd /var/www/html && git clone $gitRepoUrl . && chown -R www-data:www-data ."
    }

    Set-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "CustomScript" -Publisher "Microsoft.Azure.Extensions" -Type "CustomScript" -TypeHandlerVersion "2.1" -Setting $publicSettings
}

Write-Host "Load Balancer is successfully created and configured."

