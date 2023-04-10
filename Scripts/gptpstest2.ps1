# Set variables for your resource group, location, and load balancer name
$ResourceGroupName = "yourResourceGroupName"
$Location = "East US"
$LoadBalancerName = "mikeLB"

# Create a new resource group if it doesn't exist
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Ignore

# Create a public IP address for the load balancer
$PublicIp = New-AzPublicIpAddress -Name "${LoadBalancerName}PublicIp" -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic

# Create a frontend IP configuration
$FrontendIpConfig = New-AzLoadBalancerFrontendIpConfig -Name "${LoadBalancerName}FrontendIpConfig" -PublicIpAddress $PublicIp

# Create a backend address pool
$BackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "${LoadBalancerName}BackendAddressPool"

# Create a health probe
$HealthProbe = New-AzLoadBalancerProbeConfig -Name "${LoadBalancerName}HealthProbe" -Protocol Http -Port 80 -IntervalInSeconds 15 -ProbeCount 2 -RequestPath "/"

# Create a load balancing rule
$LoadBalancingRule = New-AzLoadBalancerRuleConfig -Name "${LoadBalancerName}LoadBalancingRule" -FrontendIpConfiguration $FrontendIpConfig -BackendAddressPool $BackendAddressPool -Probe $HealthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -LoadDistribution Default -IdleTimeoutInMinutes 4

# Create the load balancer with the configurations
New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName -Location $Location -FrontendIpConfiguration $FrontendIpConfig -BackendAddressPool $BackendAddressPool -Probe $HealthProbe -LoadBalancingRule $LoadBalancingRule
