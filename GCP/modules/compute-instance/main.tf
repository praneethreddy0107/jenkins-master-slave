resource "google_compute_instance" "instance" {

  project                   = var.project_id
  zone                      = var.zone
  name                      = var.name
  hostname                  = var.hostname
  description               = var.description
  tags                      = var.tags
  machine_type              = var.instance_type
  min_cpu_platform          = var.min_cpu_platform
  can_ip_forward            = var.can_ip_forward
  allow_stopping_for_update = var.options.allow_stopping_for_update
  deletion_protection       = var.options.deletion_protection
  enable_display            = var.enable_display
  labels                    = var.labels
  metadata                  = var.metadata
  metadata_startup_script   = var.metadata_startup_script
  boot_disk {
    auto_delete = (
      var.boot_disk.use_independent_disk
      ? false
      : var.boot_disk.auto_delete
    )
    disk_encryption_key_raw = (
      var.encryption != null ? var.encryption.disk_encryption_key_raw : null
    )

    kms_key_self_link = (
      var.encryption != null ? var.encryption.kms_key_self_link : null
    )

    dynamic "initialize_params" {
      for_each = (
        var.boot_disk.initialize_params == null
        ||
        var.boot_disk.use_independent_disk
        ? []
        : [""]
      )
      content {
        image = var.boot_disk.initialize_params.image
        size  = var.boot_disk.initialize_params.size
        type  = var.boot_disk.initialize_params.type
      }
    }
  }
  dynamic "confidential_instance_config" {
    for_each = var.confidential_compute ? [""] : []
    content {
      enable_confidential_compute = true
    }
  }
  dynamic "network_interface" {
    for_each = var.network_interfaces
    iterator = config
    content {
      network    = config.value.network
      subnetwork = config.value.subnetwork
      network_ip = try(config.value.addresses.internal, null)
      nic_type   = config.value.nic_type
      stack_type = config.value.stack_type
      dynamic "access_config" {
        for_each = var.enable_public_ip || config.value.nat ? [""] : []
        content {
          nat_ip = try(config.value.addresses.external, null)
        }
      }

      # dynamic "access_config" {
      #   for_each = var.enable_public_ip || config.value.nat ? [1] : []
      #   content {
      #     nat_ip = lookup(config.value, "addresses", null) != null ? lookup(config.value.addresses, "external", null) : null
      #   }
      # }

      dynamic "alias_ip_range" {
        for_each = config.value.alias_ips
        iterator = config_alias
        content {
          subnetwork_range_name = config_alias.key
          ip_cidr_range         = config_alias.value
        }
      }
    }
  }


  scheduling {
    automatic_restart           = !var.options.spot
    instance_termination_action = local.termination_action
    on_host_maintenance         = local.on_host_maintenance
    preemptible                 = var.options.spot
    provisioning_model          = var.options.spot ? "SPOT" : "STANDARD"

    dynamic "node_affinities" {
      for_each = var.options.node_affinities
      iterator = affinity
      content {
        key      = affinity.key
        operator = affinity.value.in ? "IN" : "NOT_IN"
        values   = affinity.value.values
      }
    }
  }
  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [""]
    content {
      email  = local.service_account.email
      scopes = local.service_account.scopes
    }
  }

  dynamic "shielded_instance_config" {
    for_each = var.shielded_config != null ? [var.shielded_config] : []
    iterator = config
    content {
      enable_secure_boot          = config.value.enable_secure_boot
      enable_vtpm                 = config.value.enable_vtpm
      enable_integrity_monitoring = config.value.enable_integrity_monitoring
    }
  }
}
