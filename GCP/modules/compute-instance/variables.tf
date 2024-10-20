variable "boot_disk" {
  description = "Boot disk properties."
  type = object({
    auto_delete       = optional(bool, true)
    snapshot_schedule = optional(string)
    source            = optional(string)
    initialize_params = optional(object({
      image = optional(string, "projects/debian-cloud/global/images/family/debian-11")
      size  = optional(number, 10)
      type  = optional(string, "pd-balanced")
    }))
    use_independent_disk = optional(bool, false)
  })
  default = {
    initialize_params = {}
  }
  nullable = false
  validation {
    condition = (
      (var.boot_disk.source == null ? 0 : 1) +
      (var.boot_disk.initialize_params == null ? 0 : 1) < 2
    )
    error_message = "You can only have one of boot disk source or initialize params."
  }
  validation {
    condition = (
      var.boot_disk.use_independent_disk != true
      ||
      var.boot_disk.initialize_params != null
    )
    error_message = "Using an independent disk for boot requires initialize params."
  }
}

variable "can_ip_forward" {
  description = "Enable IP forwarding."
  type        = bool
  default     = false
}

variable "confidential_compute" {
  description = "Enable Confidential Compute for these instances."
  type        = bool
  default     = false
}
variable "description" {
  description = "Description of a Compute Instance."
  type        = string
  default     = "Managed by the compute-vm Terraform module."
}
variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "f1-micro"
}

variable "labels" {
  description = "Instance labels."
  type        = map(string)
  default     = {}
}

variable "metadata" {
  description = "Instance metadata."
  type        = map(string)
  default     = {}
}

variable "min_cpu_platform" {
  description = "Minimum CPU platform."
  type        = string
  default     = null
}

variable "name" {
  description = "Instance name."
  type        = string
}

variable "network_attached_interfaces" {
  description = "Network interfaces using network attachments."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "network_interfaces" {
  description = "Network interfaces configuration. Use self links for Shared VPC, set addresses to null if not needed."
  type = list(object({
    network    = string
    subnetwork = string
    alias_ips  = optional(map(string), {})
    nat        = optional(bool, false)
    nic_type   = optional(string)
    stack_type = optional(string)
    addresses = optional(object({
      internal = optional(string)
      external = optional(string)
    }), null)
  }))
}

variable "options" {
  description = "Instance options."
  type = object({
    allow_stopping_for_update = optional(bool, true)
    deletion_protection       = optional(bool, false)
    node_affinities = optional(map(object({
      values = list(string)
      in     = optional(bool, true)
    })), {})
    spot               = optional(bool, false)
    termination_action = optional(string)
  })
  default = {
    allow_stopping_for_update = true
    deletion_protection       = false
    spot                      = false
    termination_action        = null
  }
  validation {
    condition = (var.options.termination_action == null
      ||
    contains(["STOP", "DELETE"], coalesce(var.options.termination_action, "1")))
    error_message = "Allowed values for options.termination_action are 'STOP', 'DELETE' and null."
  }
}

variable "project_id" {
  description = "Project id."
  type        = string
}

variable "tags" {
  description = "Instance network tags for firewall rule targets."
  type        = list(string)
  default     = []
}

variable "zone" {
  description = "Compute zone."
  type        = string
}
variable "hostname" {
  description = "Instance FQDN name."
  type        = string
  default     = null
}


variable "enable_display" {
  description = "Enable virtual display on the instances."
  type        = bool
  default     = false
}

variable "encryption" {
  description = "Encryption options. Only one of kms_key_self_link and disk_encryption_key_raw may be set. If needed, you can specify to encrypt or not the boot disk."
  type = object({
    encrypt_boot            = optional(bool, false)
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
  })
  default = null
}



variable "tag_bindings" {
  description = "Resource manager tag bindings for this instance, in tag key => tag value format."
  type        = map(string)
  default     = null
}

variable "tag_bindings_firewall" {
  description = "Firewall (network scoped) tag bindings for this instance, in tag key => tag value format."
  type        = map(string)
  default     = null
}


variable "service_account" {
  description = "Service account email and scopes. If email is null, the default Compute service account will be used unless auto_create is true, in which case a service account will be created. Set the variable to null to avoid attaching a service account."
  type = object({
    auto_create = optional(bool, false)
    email       = optional(string)
    scopes      = optional(list(string))
  })
  default = {}
}


variable "shielded_config" {
  description = "Shielded VM configuration of the instances."
  type = object({
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    enable_integrity_monitoring = bool
  })
  default = null
}

variable "enable_public_ip" {
  description = "Flag to enable or disable public IP for the instance."
  type        = bool
  default     = false  # Set the default value to false, meaning no public IP by default
}
variable "metadata_startup_script" {
  description = "The startup script rendered by a template file."
  type        = string
  default     = ""  # Default empty value if no script is provided
}
