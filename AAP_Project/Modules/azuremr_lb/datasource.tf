data "azurerm_network_interface" "datanicblock1" {
    for_each = var.lb
  name                = each.value.frontendvm1-nic
  resource_group_name = each.value.resource_group_name
}

data "azurerm_network_interface" "datanicblock2" {
    for_each = var.lb
  name                = each.value.frontendvm2-nic
  resource_group_name = each.value.resource_group_name
}