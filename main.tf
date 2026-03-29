
locals {
  network_id          = openstack_networking_network_v2.main # data.openstack_networking_network_v2.main
  network_cidr_v4     = try(one([for ip in var.network_cidr : ip if length(split(".", ip)) > 1]), "")
  network_cidr_v6_tmp = try(one([for ip in var.network_cidr : ip if length(split(":", ip)) > 1]), "")
  network_cidr_v6     = cidrsubnet(local.network_cidr_v6_tmp, 0, 0) # cidrsubnet(var.network_cidr[1], 8, var.network_shift * 8)
}

resource "openstack_networking_subnet_v2" "public" {
  for_each   = { for idx, name in var.regions : name => idx }
  region     = each.key
  name       = "public"
  network_id = local.network_id[each.key].id
  cidr       = cidrsubnet(local.network_cidr_v4, 8, (var.network_shift + each.value) * 4)
  no_gateway = true
  allocation_pool {
    start = cidrhost(cidrsubnet(local.network_cidr_v4, 8, (var.network_shift + each.value) * 4), 128)
    end   = cidrhost(cidrsubnet(local.network_cidr_v4, 8, (var.network_shift + each.value) * 4), -7)
  }
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

resource "openstack_networking_subnet_v2" "public_v6" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  name              = "public-v6"
  network_id        = local.network_id[each.key].id
  cidr              = cidrsubnet(cidrsubnet(local.network_cidr_v6, 6, (var.network_shift + each.value)), 10, 0) # to get /64 from /56
  no_gateway        = true
  ip_version        = 6
  ipv6_address_mode = "slaac" # dhcpv6-stateless dhcpv6-stateful # slaac
  # ipv6_ra_mode      = "slaac" # dhcpv6-stateless dhcpv6-stateful
  dns_nameservers = ["2001:4860:4860::8888"]
}

resource "openstack_networking_subnet_v2" "private" {
  for_each   = { for idx, name in var.regions : name => idx }
  region     = each.key
  name       = "private"
  network_id = local.network_id[each.key].id
  cidr       = cidrsubnet(local.network_cidr_v4, 8, 1 + (var.network_shift + each.value) * 4)
  allocation_pool {
    start = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 1 + (var.network_shift + each.value) * 4), 128)
    end   = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 1 + (var.network_shift + each.value) * 4), -7)
  }
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

resource "openstack_networking_subnet_v2" "metal" {
  for_each   = { for idx, name in var.regions : name => idx }
  region     = each.key
  name       = "metal"
  network_id = local.network_id[each.key].id
  cidr       = cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + each.value) * 4)
  gateway_ip = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + each.value) * 4), 1)
  allocation_pool {
    start = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + each.value) * 4), 32)
    end   = cidrhost(cidrsubnet(local.network_cidr_v4, 8, 2 + (var.network_shift + each.value) * 4), 47)
  }
  ip_version  = 4
  enable_dhcp = false
}

# resource "openstack_networking_subnet_route_v2" "public_v4" {
#   for_each         = { for idx, name in var.regions : name => idx if data.openstack_networking_quota_v2.quota[name].router > 0 }
#   region           = each.key
#   subnet_id        = openstack_networking_subnet_v2.public[each.key].id
#   destination_cidr = local.network_cidr_v4
#   next_hop         = try(var.capabilities[each.key].gateway, false) ? cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 2) : cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 1)
# }

# resource "openstack_networking_subnet_route_v2" "private_v4" {
#   for_each         = { for idx, name in var.regions : name => idx if data.openstack_networking_quota_v2.quota[name].router > 0 }
#   region           = each.key
#   subnet_id        = openstack_networking_subnet_v2.private[each.key].id
#   destination_cidr = local.network_cidr_v4
#   next_hop         = try(var.capabilities[each.key].gateway, false) ? cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 2) : cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 1)
# }

# resource "openstack_networking_subnet_route_v2" "metale_v4" {
#   for_each         = { for idx, name in var.regions : name => idx if data.openstack_networking_quota_v2.quota[name].router > 0 }
#   region           = each.key
#   subnet_id        = openstack_networking_subnet_v2.metal[each.key].id
#   destination_cidr = local.network_cidr_v4
#   next_hop         = try(var.capabilities[each.key].gateway, false) ? cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 2) : cidrhost(openstack_networking_subnet_v2.private[each.key].cidr, 1)
# }

# resource "openstack_networking_subnet_route_v2" "private_v6" {
#   for_each         = { for idx, name in var.regions : name => idx if data.openstack_networking_quota_v2.quota[name].router > 0 }
#   region           = each.key
#   subnet_id        = openstack_networking_subnet_v2.private_v6[each.key].id
#   destination_cidr = var.network_cidr[1]
#   next_hop         = cidrhost(openstack_networking_subnet_v2.private_v6[each.key].cidr, 1)
# }
