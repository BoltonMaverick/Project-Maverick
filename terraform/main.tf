# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = " 3.37.0 "
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "mav" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}


#create a virtual network group

resource "azurerm_virtual_network" "mav-vn" {
  name                = "mav-network"
  resource_group_name = azurerm_resource_group.mav.name
  location            = azurerm_resource_group.mav.location
  address_space       = ["10.125.0.0/16"]

  tags = var.tags
}

#create resorce subnet

resource "azurerm_subnet" "mav-subnet" {
  name                 = "mav-subnet"
  resource_group_name  = azurerm_resource_group.mav.name
  virtual_network_name = azurerm_virtual_network.mav-vn.name
  address_prefixes     = ["10.125.1.0/24"]
}
#create network security group

resource "azurerm_network_security_group" "mav-sg" {
  name                = "mav-sg"
  location            = azurerm_resource_group.mav.location
  resource_group_name = azurerm_resource_group.mav.name

  tags = var.tags
}

#create network security rule 

resource "azurerm_network_security_rule" "mav-dev-rule" {
  name                        = "mav-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mav.name
  network_security_group_name = azurerm_network_security_group.mav-sg.name
}
resource "azurerm_network_security_rule" "mav-sql-rule" {
  name                        = "mav-allow-sql-server"
  resource_group_name         = azurerm_resource_group.mav.name
  network_security_group_name = azurerm_network_security_group.mav-sg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

#create subnet network security group 

resource "azurerm_subnet_network_security_group_association" "mav-sgn" {
  subnet_id                 = azurerm_subnet.mav-subnet.id
  network_security_group_id = azurerm_network_security_group.mav-sg.id
}

#create public ip

resource "azurerm_public_ip" "mav-ip" {
  name                = "mav-ip"
  resource_group_name = azurerm_resource_group.mav.name
  location            = azurerm_resource_group.mav.location
  allocation_method   = "Dynamic"

  tags = var.tags
}


resource "azurerm_network_interface" "mav-nic" {
  name                = "mav-nic"
  location            = azurerm_resource_group.mav.location
  resource_group_name = azurerm_resource_group.mav.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mav-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mav-ip.id
  }
  tags = var.tags
}

#create Virtual machine

resource "azurerm_linux_virtual_machine" "mav-vm" {
  name                = "mav-vm"
  resource_group_name = azurerm_resource_group.mav.name
  location            = azurerm_resource_group.mav.location
  size                = var.virtual_machine_.ami_size
  admin_username      = var.virtual_machine_.admin_username
  admin_password      = var.virtual_machine_.admin_password

  disable_password_authentication = false
  allow_extension_operations      = true

  # custom_data = filebase64("customdata.tpl")

  network_interface_ids = [
    azurerm_network_interface.mav-nic.id,
  ]
  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/mavazurekey.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

}

# Create a MySQL server
resource "azurerm_mysql_server" "mav-sql" {
  name                = "mav-server"
  resource_group_name = azurerm_resource_group.mav.name
  location            = azurerm_resource_group.mav.location
  version             = "5.7"

  administrator_login          = var.mysql_database.db_username
  administrator_login_password = var.mysql_database.db_password

  sku_name                         = "B_Gen5_2"
  storage_mb                       = 5120
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"


}

# Create a MySQL database
resource "azurerm_mysql_database" "mav-db" {
  name                = var.mysql_database.db_name
  resource_group_name = azurerm_resource_group.mav.name
  server_name         = azurerm_mysql_server.mav-sql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_app_service_plan" "mav-service" {
  name                = "mav-appserviceplan"
  location            = azurerm_resource_group.mav.location
  resource_group_name = azurerm_resource_group.mav.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "mavi-app" {
  name                = "buzzcorp-mav"
  location            = azurerm_resource_group.mav.location
  resource_group_name = azurerm_resource_group.mav.name
  app_service_plan_id = azurerm_app_service_plan.mav-service.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = var.connection_string.name
    type  = var.connection_string.type
    value = var.connection_string.value
  }
}

