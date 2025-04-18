data "azurerm_resource_group" "example" {
  name = var.rg_nombre
}

module "vnet" {
  source = "./vnet"
  resource_group_name = data.azurerm_resource_group.example.name
  virtual_network_name = var.subnet_name
  subnet_name = var.subnet_name
  public_ip_name = var.public_ip_name
  location = data.azurerm_resource_group.example.location
}

module "vm" {
  source = "./vm"
  password = var.password
  username = var.username
  location = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  virtual_machine_name = var.virtual_machine_name
  redundancy_type = var.redundancy_type
  backend_address_pool_id = module.loadbalancer.backend_address_pool_id
  disk_name = var.disk_name
  subnet_id = module.vnet.subnet_id
  network_interface_name = var.network_interface_name
  virtual_machine_size = var.virtual_machine_size
}

module "loadbalancer" {
  source = "./loadbalancer"
  public_ip_address_id = module.vnet.public_ip_address_id
  location = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  load_balancer_name = var.load_balancer_name
}

module "nsg" {
  source = "./nsg"
  location = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  subnet_id = module.vnet.subnet_id
  network_security_group_name = var.network_security_group_name
}