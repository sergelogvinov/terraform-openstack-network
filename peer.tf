
resource "openstack_compute_keypair_v2" "keypair" {
  for_each   = { for idx, name in var.regions : name => idx if var.ssh_key != "" }
  region     = each.key
  name       = "Terraform keypair"
  public_key = var.ssh_key
}

data "openstack_images_image_v2" "debian" {
  for_each    = { for idx, zone in var.regions : zone => idx if lookup(try(var.capabilities[zone], {}), "network_peer_enable", false) }
  region      = each.key
  name        = "Debian 13"
  most_recent = true
  visibility  = "public"
}

resource "openstack_networking_port_v2" "router_external" {
  for_each           = { for idx, zone in var.regions : zone => idx if lookup(try(var.capabilities[zone], {}), "network_peer_enable", false) }
  region             = each.key
  name               = "router-${lower(each.key)}"
  network_id         = data.openstack_networking_network_v2.external[each.key].id
  security_group_ids = [openstack_networking_secgroup_v2.router[each.key].id]
  admin_state_up     = "true"
}

resource "openstack_networking_port_v2" "router" {
  for_each       = { for idx, zone in var.regions : zone => idx if lookup(try(var.capabilities[zone], {}), "network_peer_enable", false) }
  region         = each.key
  name           = "router-${lower(each.key)}"
  network_id     = local.network_id[each.key].id
  admin_state_up = "true"

  port_security_enabled = false
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.public[each.key].id
    ip_address = cidrhost(openstack_networking_subnet_v2.public[each.key].cidr, 1)
  }
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_v6[each.key].id
    # ip_address = cidrhost(openstack_networking_subnet_v2.private_v6[each.key].cidr, 1)
  }
}

resource "openstack_compute_instance_v2" "router" {
  for_each    = { for idx, zone in var.regions : zone => idx if lookup(try(var.capabilities[zone], {}), "network_peer_enable", false) }
  region      = each.key
  name        = "router-${lower(each.key)}"
  image_id    = data.openstack_images_image_v2.debian[each.key].id
  flavor_name = try(lookup(try(var.capabilities[each.key], {}), "network_peer_type", "d2-2"))
  key_pair    = try(openstack_compute_keypair_v2.keypair[each.key].name, null)

  network {
    port           = openstack_networking_port_v2.router_external[each.key].id
    uuid           = openstack_networking_port_v2.router_external[each.key].network_id
    access_network = true
  }
  network {
    port = openstack_networking_port_v2.router[each.key].id
  }

  user_data = <<EOF
  #cloud-config
  apt_update: true
  apt_upgrade: true
  disable_root: false
  write_files:
    - path: /etc/systemd/network/60-ens4.network
      owner: root:systemd-network
      permissions: '0644'
      content: |
        [Match]
        PermanentMACAddress=${openstack_networking_port_v2.router[each.key].mac_address}

        [Network]
        DHCP=yes
        Address=${[for ip in openstack_networking_port_v2.router[each.key].all_fixed_ips : ip if length(split(".", ip)) > 1][0]}/24
        Address=${[for ip in openstack_networking_port_v2.router[each.key].all_fixed_ips : ip if length(split(":", ip)) > 1][0]}/56
        Address=${cidrhost(openstack_networking_subnet_v2.private_v6[each.key].cidr, 1)}/128

        [DHCP]
        RouteMetric=100
  runcmd:
    - rm -f /run/systemd/network/10-netplan-ens4.network
    - networkctl reload
  EOF

  lifecycle {
    ignore_changes = [key_pair, user_data, image_id]
  }
}
