
resource "openstack_networking_router_v2" "nat" {
  for_each            = { for idx, region in var.regions : region => idx if lookup(try(var.capabilities[region], {}), "network_nat_enable", false) }
  region              = each.key
  name                = "nat-${openstack_networking_subnet_v2.private[each.key].name}"
  external_network_id = data.openstack_networking_network_v2.external[each.key].id
  admin_state_up      = true

  # external_fixed_ip {
  #   subnet_id  = data.openstack_networking_network_v2.external[each.key].id
  #   ip_address = [for ip in openstack_networking_port_v2.nat[each.key].all_fixed_ips : ip if length(split(".", ip)) > 1][0]
  # }
}

resource "openstack_networking_router_interface_v2" "private" {
  for_each  = { for idx, region in var.regions : region => idx if lookup(try(var.capabilities[region], {}), "network_nat_enable", false) }
  region    = each.key
  router_id = openstack_networking_router_v2.nat[each.key].id
  subnet_id = openstack_networking_subnet_v2.private[each.key].id
}
