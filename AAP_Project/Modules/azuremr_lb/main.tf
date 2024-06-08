resource "azurerm_public_ip" "pipblock" {
    for_each = var.lb
  name                = each.value.lbpip 
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = each.value.allocation_method
  sku = "Standard"
}

resource "azurerm_lb" "lbblock" {
    for_each = var.lb
  name                = each.value.lbname
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pipblock[each.key].id
  }
}


resource "azurerm_lb_backend_address_pool" "pool" {
    for_each = var.lb
  name = each.value.backendpool
  loadbalancer_id = azurerm_lb.lbblock[each.key].id

}



resource "azurerm_network_interface_backend_address_pool_association" "nicattach1" {
    for_each = var.lb
  network_interface_id    = data.azurerm_network_interface.datanicblock1[each.key].id
  ip_configuration_name   = each.value.ip_configuration_name1
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool[each.key].id
}


resource "azurerm_network_interface_backend_address_pool_association" "nicattach2" {
    for_each = var.lb
  network_interface_id    = data.azurerm_network_interface.datanicblock2[each.key].id
  ip_configuration_name   = each.value.ip_configuration_name2
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool[each.key].id
}

resource "azurerm_lb_probe" "probeblock" {
    for_each = var.lb
  loadbalancer_id = azurerm_lb.lbblock[each.key].id
  name            = "ssh-running-probe"
  port            = 22
}

resource "azurerm_lb_rule" "lbrule" {
    for_each = var.lb
  loadbalancer_id                = azurerm_lb.lbblock[each.key].id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.pool[each.key].id]
  probe_id = azurerm_lb_probe.probeblock[each.key].id
}