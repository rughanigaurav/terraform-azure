terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">=0.0.0"
    }
  }
}

provider "azurerm" {

    skip_provider_registration = true
    features {}
  
}


#Define Name and Location for all resources

# resource "azurerm_resource_group" "gaurav" {
    
#     name = "gaurav-resource"
#     location = "West Europe"

# }

#Define Name and Location for all resources

resource "azurerm_resource_group" "gaurav" {
    
    name = "gaurav-resource"
    location = "North Europe"

}

data "azurerm_subnet" "Subnet1" {

    name = "Subnet1"
    virtual_network_name = azurerm_virtual_network.gaurav.name
    resource_group_name = azurerm_resource_group.gaurav.name
  
}


#Create Storage group

resource "azurerm_storage_account" "gaurav" {
    
    name = "terraformazure191091"
    resource_group_name = azurerm_resource_group.gaurav.name
    location = azurerm_resource_group.gaurav.location
    account_tier = "Standard"
    account_replication_type = "GRS"

tags = {

    name = "test"

}

}


#Create storage group Container

resource "azurerm_storage_container" "gaurav" {
    name = "test"
    storage_account_name = "terraformazure191091"
    container_access_type = "private"
  
}


#Create Blob storage

resource "azurerm_storage_blob" "gaurav" {

    name = "first"
    storage_account_name = "terraformazure191091"
    storage_container_name = "test"
    type = "Block"
  
}


#Create Virtual Network for Private VPC

resource "azurerm_virtual_network" "gaurav" {

    name = "VPC-Network"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.gaurav.location
    resource_group_name = azurerm_resource_group.gaurav.name
  
}


#Create VPC Subnet

resource "azurerm_subnet" "gaurav" {

    name = "VPC-Subnet1"
    resource_group_name = azurerm_resource_group.gaurav.name
    virtual_network_name = azurerm_virtual_network.gaurav.name
    address_prefixes = ["10.0.1.0/24"]

}



#Create Netowork Interface

resource "azurerm_network_interface" "gaurav" {

    name = "nic"
    location = azurerm_resource_group.gaurav.location
    resource_group_name = azurerm_resource_group.gaurav.name
  
    ip_configuration {
      name = "nic"
      subnet_id = data.azurerm_subnet.Subnet1.id
      private_ip_address_allocation = "Dynamic"

    }
}


#Create Network-Security-Group

resource "azurerm_network_security_group" "gaurav" {

    name = "NSG"
    location = azurerm_resource_group.gaurav.location
    resource_group_name = azurerm_resource_group.gaurav.name

    security_rule {

        name = "SSH"
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    
    security_rule {
        name = "HTTP"
        priority = 103
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }

    security_rule {
        name = "HTTPS"
        priority = 102
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "443"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }

    security_rule {

        name = "POSTGRES-SQL"
        priority = 104
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "5432"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }

    security_rule {

        name = "HTTPS"
        priority = 105
        direction = "Outbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "*"
        source_address_prefix = "*"
        destination_address_prefix = "*"


    }

}
  

#Create Windows VMS

resource "azurerm_windows_virtual_machine" "gaurav" {

    name = "Virtual-Machine"
    resource_group_name = azurerm_resource_group.gaurav.name
    location = azurerm_resource_group.gaurav.location
    size = "Standard_F2"
    admin_username = "gaurav"
    admin_password = "admin@123"
    
    network_interface_ids = [
        azurerm_network_interface.gaurav.id,
    ]
  
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"

    }

    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer = "WindowsServer"
      sku = "2019-Datacenter"
      version = "latest"
    }
}