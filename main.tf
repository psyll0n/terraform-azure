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