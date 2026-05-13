
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
    cidr_v6    = openstack_networking_subnet_v2.private_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.private_v6[zone].cidr, 1)
    mtu        = local.network_id[zone].mtu
  } }
}

output "network_private" {
  description = "The private network"
  value = { for zone, subnet in openstack_networking_subnet_v2.private : zone => {
    network_id = subnet.network_id
    subnet_id  = subnet.id
    cidr_v4    = subnet.cidr
    cidr_v6    = openstack_networking_subnet_v2.private_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.private_v6[zone].cidr, 1)
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
    cidr_v6    = openstack_networking_subnet_v2.private_v6[zone].cidr
    gateway_v4 = subnet.gateway_ip != "" ? subnet.gateway_ip : cidrhost(subnet.cidr, 1)
    gateway_v6 = cidrhost(openstack_networking_subnet_v2.private_v6[zone].cidr, 1)
    peer       = cidrhost(openstack_networking_subnet_v2.private[zone].cidr, try(var.capabilities[zone].gateway, false) && data.openstack_networking_quota_v2.quota[zone].router > 0 ? 2 : 1)
    mtu        = local.network_id[zone].mtu
  } }
}

output "networks" {
  description = "Regional networks"
  value = merge({ for idx, zone in var.regions : zone => {
    cidr_v4   = local.network_subnet_v4[zone]
    cidr_v6   = local.network_subnet_v6[zone]
    peer_gwv4 = cidrhost(openstack_networking_subnet_v2.public[zone].cidr, lookup(try(var.capabilities[zone], {}), "network_nat_enable", false) ? 2 : 1)
    peer_gwv6 = cidrhost(openstack_networking_subnet_v2.private_v6[zone].cidr, 1)
    peer_mtu  = 1420
    } },
    {
      "ALL" : {
        cidr_v4    = local.network_cidr_v4
        cidr_v6    = local.network_cidr_v6
        network_v4 = one([for ip in var.network_cidr : ip if length(split(".", ip)) > 1])
        network_v6 = one([for ip in var.network_cidr : ip if length(split(":", ip)) > 1])
      }
  })
}

output "network_nat" {
  description = "The nat ips"
  value = { for idx, zone in var.regions : zone => {
    ip_v4 = [for ip in openstack_networking_router_v2.nat[zone].external_fixed_ip : ip.ip_address if length(split(".", ip.ip_address)) > 1]
  } if lookup(try(var.capabilities[zone], {}), "network_nat_enable", false) }
}

output "network_secgroup" {
  description = "The Network Security Groups"
  value = { for idx, zone in var.regions : zone => {
    common       = openstack_networking_secgroup_v2.common[zone].id
    controlplane = openstack_networking_secgroup_v2.controlplane[zone].id
    web          = openstack_networking_secgroup_v2.web[zone].id
  } }
}

output "network_peering" {
  value = { for k, v in local.ipsec_tunnels : k => {
    server = {
      asn  = v.server_asn
      ip4  = v.server_v4
      ip6  = v.server_v6
      p2p4 = v.server_p2p_v4
      p2p6 = v.server_p2p_v6
    }
    client = {
      asn  = v.peer_asn
      ip4  = v.peer_v4
      ip6  = v.peer_v6
      p2p4 = v.peer_p2p_v4
      p2p6 = v.peer_p2p_v6
    }
    }
  }
}
