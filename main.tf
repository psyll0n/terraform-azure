terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name = "azuredevtestrg"
  location = "West Europe"
}

# VNET definition - Create a single VNET.
resource "azurerm_resource_group" "vnet" {
  name     = "DevTestVnet"
  location = "West Europe"
}


resource "azurerm_virtual_network" "myterraformnetwork" {
    resource_group_name = azurerm_resource_group.rg.name
    name                = "DevTestVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "West Europe"
  
    tags = {
        environment = "Terraform Demo"
    }

  depends_on = [azurerm_resource_group.rg]
}

# Subnets definition - Create three subnets.

resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "DevTestSubnet1"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "DevTestSubnet2"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "myterraformsubnet3" {
    name                 = "DevTestSubnet3"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.3.0/24"]
}


# Route table definition - Create three route tables.


resource "azurerm_route_table" "RouteTable1" {
  name                          = "DevTestRouteTable1"
  location                      = "West Europe"
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route2"
    address_prefix = "10.0.2.0/24"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route3"
    address_prefix = "10.0.3.0/24"
    next_hop_type  = "vnetlocal"
  }
}

resource "azurerm_route_table" "RouteTable2" {
  name                          = "DevTestRouteTable2"
  location                      = "West Europe"
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route2"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route3"
    address_prefix = "10.0.3.0/24"
    next_hop_type  = "vnetlocal"
  }
}


resource "azurerm_route_table" "RouteTable3" {
  name                          = "DevTestRouteTable3"
  location                      = "West Europe"
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false
  

  route {
    name           = "route1"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route2"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "vnetlocal"
  }

  route {
    name           = "route3"
    address_prefix = "10.0.2.0/24"
    next_hop_type  = "vnetlocal"
  }
}

# Route table to subnet association. 

resource "azurerm_subnet_route_table_association" "rtb1" {
  subnet_id      = azurerm_subnet.myterraformsubnet1.id
  route_table_id = azurerm_route_table.RouteTable1.id
}

resource "azurerm_subnet_route_table_association" "rtb2" {
  subnet_id      = azurerm_subnet.myterraformsubnet2.id
  route_table_id = azurerm_route_table.RouteTable2.id
}

resource "azurerm_subnet_route_table_association" "rtb3" {
  subnet_id      = azurerm_subnet.myterraformsubnet3.id
  route_table_id = azurerm_route_table.RouteTable3.id
}


# Define a dynamic public IP address.

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "DynamicPublicIP1"
    location                     = "West Europe"
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
}


# Define a Network Security Group.

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "DevTestNSG"
    location            = "West Europe"
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Define a Network Interface Card.

resource "azurerm_network_interface" "myterraformnic" {
    name                        = "DevTestNIC"
    location                    = "West Europe"
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }
}

# Connect the security group to the network interface.

resource "azurerm_network_interface_security_group_association" "nsgassociation" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}


# Define a storage account. 

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "tfdevteststorageaccount"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = "West Europe"
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

# Define a ssh key-pair.

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }


# Create a terraform VM. 

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "DevTestVM"
    location              = "West Europe"
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "DevTestVM"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
}