
resource "openstack_networking_secgroup_v2" "common" {
  for_each    = { for idx, name in var.regions : name => idx }
  region      = each.key
  name        = "common"
  description = "Security group for all nodes"
}

resource "openstack_networking_secgroup_rule_v2" "common_icmp_ipv4" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.common[each.key].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
}

resource "openstack_networking_secgroup_rule_v2" "common_icmp_ipv6" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.common[each.key].id
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
}

resource "openstack_networking_secgroup_rule_v2" "common_kubespan_ipv4" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.common[each.key].id
  description       = "kubespan"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 51820
  port_range_max    = 51820
}

resource "openstack_networking_secgroup_rule_v2" "common_kubespan_ipv6" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.common[each.key].id
  description       = "kubespan"
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  port_range_min    = 51820
  port_range_max    = 51820
}

resource "openstack_networking_secgroup_rule_v2" "common_cilium_health_ipv6" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.common[each.key].id
  description       = "cilium_health"
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 4240
  port_range_max    = 4240
  remote_ip_prefix  = "::/0"
}

### Controlplane

resource "openstack_networking_secgroup_v2" "controlplane" {
  for_each    = { for idx, name in var.regions : name => idx }
  region      = each.key
  name        = "controlplane"
  description = "Security group for controlplane"
}

resource "openstack_networking_secgroup_rule_v2" "controlplane_talos_admins" {
  for_each = { for k in flatten([
    for region in var.regions : [
      for ip in var.allowlist_admins : {
        name : "controlplane-talos-admins-${lower(region)}-${ip}"
        region : region
        ip : ip
    } if length(split(".", ip)) > 1]
  ]) : k.name => k }

  region            = each.value.region
  security_group_id = openstack_networking_secgroup_v2.controlplane[each.value.region].id
  description       = "talos_admins"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  remote_ip_prefix  = each.value.ip
}

# resource "openstack_networking_secgroup_rule_v2" "controlplane_etcd" {
#   for_each = { for k in flatten([
#     for region in var.regions : [
#       for ip in var.allowlist_datacenters : {
#         name : "controlplane-etcd-${lower(region)}-${ip}"
#         region : region
#         ip : ip
#     }]
#   ]) : k.name => k }

#   region            = each.value.region
#   security_group_id = openstack_networking_secgroup_v2.controlplane[each.value.region].id
#   description       = "etcd"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 2379
#   port_range_max    = 2380
#   remote_ip_prefix  = each.value.ip
# }

resource "openstack_networking_secgroup_rule_v2" "controlplane_kubernetes_admins" {
  for_each = { for k in flatten([
    for region in var.regions : [
      for ip in sort(concat(var.allowlist_admins, var.allowlist_datacenters)) : {
        name : "controlplane-kubernetes-admins-${lower(region)}-${ip}"
        region : region
        ip : ip
    } if length(split(".", ip)) > 1]
  ]) : k.name => k }

  region            = each.value.region
  security_group_id = openstack_networking_secgroup_v2.controlplane[each.value.region].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = each.value.ip
}

resource "openstack_networking_secgroup_rule_v2" "controlplane_talos" {
  for_each = { for k in flatten([
    for region in var.regions : [
      for ip in sort(var.allowlist_datacenters) : {
        name : "controlplane-talos-${lower(region)}-${ip}"
        region : region
        ip : ip
    } if length(split(".", ip)) > 1]
  ]) : k.name => k }

  region            = each.value.region
  security_group_id = openstack_networking_secgroup_v2.controlplane[each.value.region].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50001
  remote_ip_prefix  = each.value.ip
}

### Web

resource "openstack_networking_secgroup_v2" "web" {
  for_each    = { for idx, name in var.regions : name => idx }
  region      = each.key
  name        = "web"
  description = "Security group for web"
}

resource "openstack_networking_secgroup_rule_v2" "web_http_v4" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.web[each.key].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
}

resource "openstack_networking_secgroup_rule_v2" "web_http_v6" {
  for_each          = { for idx, name in var.regions : name => idx }
  region            = each.key
  security_group_id = openstack_networking_secgroup_v2.web[each.key].id
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
}

resource "openstack_networking_secgroup_rule_v2" "web_https_v4" {
  for_each = { for k in flatten([
    for region in var.regions : [
      for ip in sort(concat(var.allowlist_admins, var.allowlist_web)) : {
        name : "web-https-v4-${lower(region)}-${ip}"
        region : region
        ip : ip
    } if length(split(".", ip)) > 1]
  ]) : k.name => k }

  region            = each.value.region
  security_group_id = openstack_networking_secgroup_v2.web[each.value.region].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = each.value.ip
}

resource "openstack_networking_secgroup_rule_v2" "web_https_v6" {
  for_each = { for k in flatten([
    for region in var.regions : [
      for ip in sort(concat(var.allowlist_admins, var.allowlist_web)) : {
        name : "web-https-v6-${lower(region)}-${ip}"
        region : region
        ip : ip
    } if length(split(":", ip)) > 1]
  ]) : k.name => k }

  region            = each.value.region
  security_group_id = openstack_networking_secgroup_v2.web[each.value.region].id
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = each.value.ip
}

###

# resource "openstack_networking_secgroup_v2" "router" {
#   for_each    = { for idx, name in var.regions : name => idx }
#   region      = each.key
#   name        = "router"
#   description = "Security group for router/peering node"
# }

# resource "openstack_networking_secgroup_rule_v2" "router_icmp_ipv4" {
#   for_each          = { for idx, name in var.regions : name => idx }
#   region            = each.key
#   security_group_id = openstack_networking_secgroup_v2.router[each.key].id
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "icmp"
# }

# resource "openstack_networking_secgroup_rule_v2" "router_ssh_v4" {
#   for_each          = { for idx, name in var.regions : name => idx }
#   region            = each.key
#   security_group_id = openstack_networking_secgroup_v2.router[each.key].id
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
# }

# resource "openstack_networking_secgroup_rule_v2" "router_ssh_v6" {
#   for_each          = { for idx, name in var.regions : name => idx }
#   region            = each.key
#   security_group_id = openstack_networking_secgroup_v2.router[each.key].id
#   direction         = "ingress"
#   ethertype         = "IPv6"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
# }

# resource "openstack_networking_secgroup_rule_v2" "router_wireguard" {
#   for_each          = { for idx, name in var.regions : name => idx }
#   region            = each.key
#   security_group_id = openstack_networking_secgroup_v2.router[each.key].id
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "udp"
#   port_range_min    = 443
#   port_range_max    = 443
# }
