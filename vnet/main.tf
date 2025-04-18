# Create a Virtual Network to host the Virtual Machines 
# in the Backend Pool of the Load Balancer
resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location #data.azurerm_resource_group.example.location
  resource_group_name = var.resource_group_name #data.azurerm_resource_group.example.name
}

# Create a subnet in the Virtual Network to host the Virtual Machines
# in the Backend Pool of the Load Balancer§
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name #data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IPs to route traffic from the Load Balancer
# to the Virtual Machines in the Backend Pool
resource "azurerm_public_ip" "example" {
  name                = "${var.public_ip_name}"
  location            = var.location #data.azurerm_resource_group.example.location
  resource_group_name = var.resource_group_name #data.azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}