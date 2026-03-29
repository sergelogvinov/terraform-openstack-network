
data "openstack_networking_quota_v2" "quota" {
  for_each   = { for idx, name in var.regions : name => idx if var.project_id != "" }
  region     = each.key
  project_id = var.project_id
}

data "openstack_networking_network_v2" "external" {
  for_each = { for idx, name in var.regions : name => idx if var.network_name_external != "" }
  region   = each.key
  name     = var.network_name_external
  external = true
}

data "openstack_networking_subnet_ids_v2" "external_v6" {
  for_each   = { for idx, name in var.regions : name => idx }
  region     = each.key
  network_id = data.openstack_networking_network_v2.external[each.key].id
  ip_version = 6
}

# data "openstack_networking_network_v2" "main" {
#   for_each = { for idx, name in var.regions : name => idx }
#   region   = each.key
#   name     = var.network_name
#   external = false
# }

resource "openstack_networking_network_v2" "main" {
  for_each       = { for idx, name in var.regions : name => idx }
  region         = each.key
  name           = var.network_name
  admin_state_up = "true"
}
