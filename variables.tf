
variable "project_id" {
  type        = string
  description = "The project_id of the openstack"
  default     = ""
}

variable "regions" {
  type        = list(string)
  description = "The id of the openstack region"
  default     = ["UK1", "GRA9", "GRA11"]
}

variable "network_name_external" {
  type    = string
  default = "Ext-Net"
}

variable "network_name" {
  type    = string
  default = "production"
}

variable "network_cidr" {
  description = "Local subnet rfc1918"
  type        = list(string)
  default     = ["172.16.0.0/16", "fd60:172:16::/48"]

  validation {
    condition     = length(var.network_cidr) == 2
    error_message = "The network_cidr is a list of IPv4/IPv6 cidr."
  }
}

variable "network_shift" {
  description = "Network number shift"
  type        = number
  default     = 4
}

# curl https://www.cloudflare.com/ips-v4 2>/dev/null | awk '{ print "\""$1"\"," }'
variable "allowlist_web" {
  description = "Cloudflare subnets"
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
  ]
}

variable "allowlist_datacenters" {
  description = "Allowlist for datacenters subnets"
  default     = []
}

variable "allowlist_admins" {
  description = "Allowlist for administrators"
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags of resources"
  type        = list(string)
  default     = ["develop"]
}

variable "capabilities" {
  type = map(any)
  default = {
    "UK1" = {
      nat          = false
      peering      = false
      peering_type = "d2-2"
    },
    "GRA9" = {
      nat          = false
      peering      = false
      peering_type = "d2-2"
    },
    "GRA11" = {
      nat          = false
      peering      = false
      peering_type = "d2-2"
    },
  }
}

variable "ssh_key" {
  description = "The ssh public key: ssh-keygen -t ed25519 -f ~/.ssh/terraform -C 'terraform'"
  type        = string
  default     = ""
}
