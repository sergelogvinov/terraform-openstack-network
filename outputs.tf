
output "regions" {
  description = "Regions"
  value       = var.regions
}

output "network_external" {
  description = "The public network"
  value = { for zone, subnet in data.openstack_networking_network_v2.external : zone => {
    name       = var.network_name_external
    id         = subnet.id
    subnets_v4 = sort(subnet.subnets)
    subnets_v6 = sort(data.openstack_networking_subnet_ids_v2.external_v6[zone].ids)
    mtu        = subnet.mtu
  } if var.network_name_external != "" }
}

output "network_public" {
  description = "The public network"
  value = { for zone, subnet in openstack_networking_subnet_v2.public : zone => {
    network_id = subnet.network_id
    subnet_id  = subnet.id
    cidr_v4    = subnet.cidr
    cidr_v6    = openstack_networking_subnet_v2.public_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.public_v6[zone].cidr, 1)
    mtu        = local.network_id[zone].mtu
  } }
}

output "network_private" {
  description = "The private network"
  value = { for zone, subnet in openstack_networking_subnet_v2.private : zone => {
    network_id = subnet.network_id
    subnet_id  = subnet.id
    cidr_v4    = subnet.cidr
    cidr_v6    = openstack_networking_subnet_v2.public_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.public_v6[zone].cidr, 1)
    peer       = cidrhost(openstack_networking_subnet_v2.private[zone].cidr, try(var.capabilities[zone].gateway, false) && data.openstack_networking_quota_v2.quota[zone].router > 0 ? 2 : 1)
    mtu        = local.network_id[zone].mtu
  } }
}

output "network_baremetal" {
  description = "The baremetal network"
  value = { for zone, subnet in openstack_networking_subnet_v2.metal : zone => {
    network_id = subnet.network_id
    subnet_id  = subnet.id
    cidr_v4    = subnet.cidr
    cidr_v6    = openstack_networking_subnet_v2.public_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.public_v6[zone].cidr, 1)
    peer       = cidrhost(openstack_networking_subnet_v2.private[zone].cidr, try(var.capabilities[zone].gateway, false) && data.openstack_networking_quota_v2.quota[zone].router > 0 ? 2 : 1)
    mtu        = local.network_id[zone].mtu
  } }
}

output "networks" {
  description = "Regional networks"
  value = { for idx, zone in var.regions : zone => {
    cidr_v4 = cidrsubnet(local.network_cidr_v4, 6, (var.network_shift + idx))
    cidr_v6 = cidrsubnet(local.network_cidr_v6, 6, (var.network_shift + idx))
  } }
}

# output "network_nat" {
#   description = "The nat ips"
#   value = { for idx, zone in var.regions : zone => {
#     ip_v4 = scaleway_vpc_public_gateway_ip.main[zone].address
#   } if try(var.capabilities[zone].network_nat_enable, false) }
# }

output "network_secgroup" {
  description = "The Network Security Groups"
  value = { for idx, zone in var.regions : zone => {
    common       = openstack_networking_secgroup_v2.common[zone].id
    controlplane = openstack_networking_secgroup_v2.controlplane[zone].id
    web          = openstack_networking_secgroup_v2.web[zone].id
  } }
}
