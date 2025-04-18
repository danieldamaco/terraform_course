# Create Network Interfaces
# The Network Interfaces will be associated with the
# Virtual Machines created later
resource "azurerm_network_interface" "example" {
  count               = 3
  name                = "${var.network_interface_name}-${count.index}"
  location            = var.location #data.azurerm_resource_group.example.location
  resource_group_name = var.resource_group_name #data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

# Associate Network Interface to the Backend Pool of the Load Balancer
# The Network Interface will be used to route traffic to the Virtual
# Machines in the Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = 3
  network_interface_id    = azurerm_network_interface.example[count.index].id
  ip_configuration_name   = "ipconfig-${count.index}"
  backend_address_pool_id = var.backend_address_pool_id #azurerm_lb_backend_address_pool.example.id
}

# Generate a random password for the VM admin users
resource "random_password" "example" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

# Create three Virtual Machines in the Backend Pool of the Load Balancer 
resource "azurerm_linux_virtual_machine" "example" {
  count                 = 3
  name                  = "${var.virtual_machine_name}-${count.index}"
  location              = var.location #data.azurerm_resource_group.example.location
  resource_group_name   = var.resource_group_name #data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example[count.index].id]
  size                  = var.virtual_machine_size

  os_disk {
    name                 = "${var.disk_name}-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = var.redundancy_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = var.username
  admin_password                  = coalesce(var.password, random_password.example.result)
  disable_password_authentication = false

}

# Enable virtual machine extension and install Nginx
# The script will update the package list, install Nginx,
# and create a simple HTML page
resource "azurerm_virtual_machine_extension" "example" {
  count                = 3
  name                 = "Nginx"
  virtual_machine_id   = azurerm_linux_virtual_machine.example[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
{
  "commandToExecute": "sudo apt-get update && sudo apt-get install -y software-properties-common && sudo add-apt-repository universe && sudo apt-get update && sudo apt-get install -y nginx && echo \"Hello World from $(hostname)-${count.index}\" | sudo tee /var/www/html/index.html && sudo systemctl restart nginx"
}
SETTINGS

}