# Terraform module for OpenStack network

## Usage Example

```hcl
module "network" {
  source = "github.com/sergelogvinov/terraform-openstack-network"

  regions = var.regions

  network_name  = "main"
  network_cidr  = ["172.16.0.0/16", "fd60:172:16::/48"]
  network_shift = 2
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | ~> 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [openstack_networking_network_v2.main](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2) | resource |
| [openstack_networking_router_interface_v2.private](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2) | resource |
| [openstack_networking_router_v2.nat](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_v2) | resource |
| [openstack_networking_secgroup_rule_v2.common_cilium_health_ipv6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.common_icmp_ipv4](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.common_icmp_ipv6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.common_kubespan_ipv4](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.common_kubespan_ipv6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.controlplane_kubernetes_admins](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.controlplane_talos](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.controlplane_talos_admins](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.web_http_v4](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.web_http_v6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.web_https_v4](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_rule_v2.web_https_v6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_v2.common](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2) | resource |
| [openstack_networking_secgroup_v2.controlplane](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2) | resource |
| [openstack_networking_secgroup_v2.web](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2) | resource |
| [openstack_networking_subnet_v2.metal](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |
| [openstack_networking_subnet_v2.private](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |
| [openstack_networking_subnet_v2.public](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |
| [openstack_networking_subnet_v2.public_v6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |
| [openstack_networking_network_v2.external](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_network_v2) | data source |
| [openstack_networking_quota_v2.quota](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_quota_v2) | data source |
| [openstack_networking_subnet_ids_v2.external_v6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_subnet_ids_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowlist_admins"></a> [allowlist\_admins](#input\_allowlist\_admins) | Allowlist for administrators | `list` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_allowlist_datacenters"></a> [allowlist\_datacenters](#input\_allowlist\_datacenters) | Allowlist for datacenters subnets | `list` | `[]` | no |
| <a name="input_allowlist_web"></a> [allowlist\_web](#input\_allowlist\_web) | Cloudflare subnets | `list` | <pre>[<br/>  "173.245.48.0/20",<br/>  "103.21.244.0/22",<br/>  "103.22.200.0/22",<br/>  "103.31.4.0/22",<br/>  "141.101.64.0/18",<br/>  "108.162.192.0/18",<br/>  "190.93.240.0/20",<br/>  "188.114.96.0/20",<br/>  "197.234.240.0/22",<br/>  "198.41.128.0/17",<br/>  "162.158.0.0/15",<br/>  "104.16.0.0/13",<br/>  "104.24.0.0/14",<br/>  "172.64.0.0/13",<br/>  "131.0.72.0/22"<br/>]</pre> | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | n/a | `map(any)` | <pre>{<br/>  "GRA11": {<br/>    "nat": false,<br/>    "peering": false,<br/>    "peering_type": "d2-2"<br/>  },<br/>  "GRA9": {<br/>    "nat": false,<br/>    "peering": false,<br/>    "peering_type": "d2-2"<br/>  },<br/>  "UK1": {<br/>    "nat": false,<br/>    "peering": false,<br/>    "peering_type": "d2-2"<br/>  }<br/>}</pre> | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Local subnet rfc1918 | `list(string)` | <pre>[<br/>  "172.16.0.0/16",<br/>  "fd60:172:16::/48"<br/>]</pre> | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | n/a | `string` | `"production"` | no |
| <a name="input_network_name_external"></a> [network\_name\_external](#input\_network\_name\_external) | n/a | `string` | `"Ext-Net"` | no |
| <a name="input_network_shift"></a> [network\_shift](#input\_network\_shift) | Network number shift | `number` | `4` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project\_id of the openstack | `string` | `""` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | The id of the openstack region | `list(string)` | <pre>[<br/>  "UK1",<br/>  "GRA9",<br/>  "GRA11"<br/>]</pre> | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The ssh public key: ssh-keygen -t ed25519 -f ~/.ssh/terraform -C 'terraform' | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of resources | `list(string)` | <pre>[<br/>  "develop"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_baremetal"></a> [network\_baremetal](#output\_network\_baremetal) | The baremetal network |
| <a name="output_network_external"></a> [network\_external](#output\_network\_external) | The public network |
| <a name="output_network_private"></a> [network\_private](#output\_network\_private) | The private network |
| <a name="output_network_public"></a> [network\_public](#output\_network\_public) | The public network |
| <a name="output_network_secgroup"></a> [network\_secgroup](#output\_network\_secgroup) | The Network Security Groups |
| <a name="output_networks"></a> [networks](#output\_networks) | Regional networks |
| <a name="output_regions"></a> [regions](#output\_regions) | Regions |
<!-- END_TF_DOCS -->