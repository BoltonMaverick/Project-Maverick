variable "location" {
  default = "East Us"
}

variable "tags" {
  default = {
    "environment" = "dev"
  }

}

#network 
# variable "network_address" {
#   type = list(string)

#   default = ["10.125.0.0/16", "10.125.1.0/24"] # first address is for azurerm_virtual_network
#   #second is for azurerm_subnet

# }

variable "resource_group" {
  default = "mavbuzz-resources"

}

# vm 
variable "virtual_machine_" {
  type = object({
    ami_size       = string
    admin_username = string
    admin_password = string
  })
  default = {
    ami_size       = "Standard_F2"
    admin_username = "adminuser"
    admin_password = "Bambam12"
  }
}


# variable "admin_ssh_key" {
#   type = object({
#     username   = string
#     public_key = any
#   })
#   default = {
#     username   = "adminuser"
#     public_key = file("~/.ssh/mavazurekey.pub")
#   }
# }



#database 
variable "mysql_database" {
  type = object({
    db_name     = string
    db_username = string
    db_password = string


  })
  default = {
    db_name     = "helpdesk_system"
    db_username = "mysqladmin"
    db_password = "Bambam12"


  }

}


variable "connection_string" {
  type = object({
    name  = string
    type  = string
    value = string
  })

  default = {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=mav-server.mysql.database.azure.com;Integrated Security=SSPI"
  }

}