
data "openstack_networking_quota_v2" "quota" {
  for_each   = { for idx, region in var.regions : region => idx if var.project_id != "" }
  region     = each.key
  project_id = var.project_id
}

data "openstack_networking_network_v2" "external" {
  for_each = { for idx, region in var.regions : region => idx if var.network_name_external != "" }
  region   = each.key
  name     = var.network_name_external
  external = true
}

data "openstack_networking_subnet_ids_v2" "external_v6" {
  for_each   = { for idx, region in var.regions : region => idx }
  region     = each.key
  network_id = data.openstack_networking_network_v2.external[each.key].id
  ip_version = 6
}

# data "openstack_networking_network_v2" "main" {
#   for_each = { for idx, region in var.regions : region => idx }
#   region   = each.key
#   name     = var.network_name
#   external = false
# }

resource "openstack_networking_network_v2" "main" {
  for_each       = { for idx, region in var.regions : region => idx if length(var.network_id) == 0 }
  region         = each.key
  name           = var.network_name
  admin_state_up = "true"
}
