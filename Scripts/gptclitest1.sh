#!/bin/bash

# Variables
resourceGroupName="myResourceGroup"
location="eastus"
publicIPName="myPublicIP"
loadBalancerName="myLoadBalancer"
backendAddressPoolName="myBackendAddressPool"
probeName="myProbe"
ruleName="myRule"
vmSize="Standard_B2s"
vmCount=3
gitRepoUrl="https://github.com/kramit/CoffeeShopTemplate.git"

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create a public IP address
az network public-ip create --name $publicIPName --resource-group $resourceGroupName --location $location --sku Standard --allocation-method Static

# Create a load balancer
az network lb create --name $loadBalancerName --resource-group $resourceGroupName --location $location --frontend-ip-name myFrontendConfig --public-ip-address $publicIPName --backend-pool-name $backendAddressPoolName

# Create load balancer health probe and rule
az network lb probe create --resource-group $resourceGroupName --lb-name $loadBalancerName --name $probeName --protocol http --port 80 --path "/" --interval 15 --threshold 2
az network lb rule create --resource-group $resourceGroupName --lb-name $loadBalancerName --name $ruleName --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name myFrontendConfig --backend-pool-name $backendAddressPoolName --probe-name $probeName

# Create virtual network and subnet
az network vnet create --name myVnet --resource-group $resourceGroupName --location $location --address-prefix "10.0.0.0/16" --subnet-name mySubnet --subnet-prefix "10.0.1.0/24"

# Create network security group and rule
az network nsg create --name myNsg --resource-group $resourceGroupName --location $location
az network nsg rule create --name "AllowHTTP" --nsg-name "myNsg" --resource-group $resourceGroupName --priority 100 --access Allow --source-address-prefixes "*" --destination-address-prefixes "*" --source-port-ranges "*" --destination-port-ranges 80 --protocol Tcp

# Create virtual machines and attach them to the load balancer
for i in $(seq 1 $vmCount); do
  vmName="myVM$i"
  nicname="myNIC$i"
  ipConfigName="myIPConfig$i"

  # Create a network interface
  az network nic create --name $nicname --resource-group $resourceGroupName --location $location --subnet mySubnet --vnet-name myVnet --network-security-group myNsg --lb-name $loadBalancerName --lb-address-pools $backendAddressPoolName

  # Create the virtual machine
  az vm create --name $vmName --resource-group $resourceGroupName --location $location --size $vmSize --nics $nicName --image "Canonical:UbuntuServer:18.04-LTS:latest" --admin-username "azureuser" --generate-ssh-keys
  
  # Install Nginx and clone the Git repository
  az vm extension set --publisher "Microsoft.Azure.Extensions" --version "2.0" --name "CustomScript" --resource-group $resourceGroupName --vm-name $vmName --settings "{\"commandToExecute\":\"apt-get update && apt-get install -y nginx git && systemctl enable nginx && systemctl start nginx && cd /var/www/html && git clone $gitRepoUrl . && chown -R www-data:www-data .\"}"
done

echo "Load Balancer is successfully created and configured."
