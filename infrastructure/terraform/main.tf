terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "azure_region" {
  description = "Azure region for deployment"
  default     = "eastus"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size for the lab target"
  default     = "Standard_B2s"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Azure VM"
  default     = "azureuser"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the Azure VM"
  default     = "P@ssw0rd1234!"
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "lab" {
  name     = "nmap-mastery-lab-rg"
  location = var.azure_region
}

resource "azurerm_virtual_network" "lab" {
  name                = "nmap-mastery-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab" {
  name                 = "lab-subnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "lab" {
  name                = "nmap-mastery-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "allow-tcp-scans"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1024-65535"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-udp-scans"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1024-65535"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "target" {
  name                = "nmap-mastery-target-pip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "target" {
  name                = "nmap-mastery-target-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.target.id
  }
}

resource "azurerm_network_interface_security_group_association" "target" {
  network_interface_id      = azurerm_network_interface.target.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_linux_virtual_machine" "target" {
  name                            = "nmap-mastery-target"
  resource_group_name             = azurerm_resource_group.lab.name
  location                        = azurerm_resource_group.lab.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.target.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/../cloud-init/nmap-mastery.yaml"))

  tags = {
    Name        = "nmap-mastery-target"
    Environment = "lab"
    Lab         = "nmap_mastery"
  }
}

output "private_ip_address" {
  value       = azurerm_linux_virtual_machine.target.private_ip_address
  description = "Private IP address of the target server"
}

output "public_ip_address" {
  value       = azurerm_public_ip.target.ip_address
  description = "Public IP address of the target server"
}
