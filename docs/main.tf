terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

########################
# PROVIDERS
########################
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "azuread" {}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

########################
# RESOURCE GROUP
########################
resource "azurerm_resource_group" "rg" {
  name     = "rg-defender-poc"
  location = "eastus2"
}

########################
# STORAGE ACCOUNT INSEGURO
########################
resource "azurerm_storage_account" "insecure" {
  name                     = "stpoc${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  timeouts {
    create = "10m"
    read   = "10m"
    update = "10m"
    delete = "10m"
  }
}

########################
# NETWORK
########################
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-poc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-poc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

########################
# NSG INSEGURO (SSH ABIERTO)
########################
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-insecure"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH-From-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

########################
# PUBLIC IP (STANDARD)
########################
resource "azurerm_public_ip" "pip" {
  name                = "pip-poc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

########################
# NIC
########################
resource "azurerm_network_interface" "nic" {
  name                = "nic-poc"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.pip
  ]

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

########################
# VM LINUX INSEGURA
########################
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-insecure"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.nic
  ]
}

########################
# IDENTIDAD INSEGURA
########################
resource "azuread_application" "app" {
  display_name = "app-poc-insecure"
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "azuread_application_password" "secret" {
  application_object_id = azuread_application.app.object_id
  end_date_relative     = "8760h"
}

########################
# PERMISOS EXCESIVOS (OWNER)
########################
resource "azurerm_role_assignment" "owner_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp.object_id
}
