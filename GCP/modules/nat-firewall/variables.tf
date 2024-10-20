variable "rules" {
  description = "This is DEPRICATED and available for backward compatiblity. Use ingress_rules and egress_rules variables. List of custom rule definitions"
  default     = []
  type = list(object({
    name                    = string
    description             = optional(string, null)
    direction               = optional(string, "INGRESS")
    disabled                = optional(bool, null)
    priority                = optional(number, null)
    ranges                  = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    log_config = optional(object({
      metadata = string
    }))
  }))

  # Validation block for 'direction'
  validation {
    condition = alltrue([for rule in var.rules : contains(["INGRESS", "EGRESS"], rule.direction)])
    error_message = "Direction must be either 'INGRESS' or 'EGRESS'."
  }

  # Validation block for 'protocol' in allow and deny
  validation {
    condition = alltrue([for rule in var.rules : alltrue([for protocol in rule.allow : contains(["ah", "all", "esp", "icmp", "ipip", "sctp", "tcp", "udp"], protocol.protocol)])])
    error_message = "Allowed protocols in 'allow' must be one of: 'ah', 'all', 'esp', 'icmp', 'ipip', 'sctp', 'tcp', 'udp'."
  }

  validation {
    condition = alltrue([for rule in var.rules : alltrue([for protocol in rule.deny : contains(["ah", "all", "esp", "icmp", "ipip", "sctp", "tcp", "udp"], protocol.protocol)])])
    error_message = "Allowed protocols in 'deny' must be one of: 'ah', 'all', 'esp', 'icmp', 'ipip', 'sctp', 'tcp', 'udp'."
  }
}

variable "project_id" {
  description = "Project id of the project that holds the network."
  type        = string
}

variable "network_name" {
  description = "Name of the network this set of firewall rules applies to."
  type        = string
}
