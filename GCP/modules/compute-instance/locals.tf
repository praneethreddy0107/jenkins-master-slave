locals{
    on_host_maintenance = (
    var.options.spot || var.confidential_compute
    ? "TERMINATE"
    : "MIGRATE"
  )
  region = join("-", slice(split("-", var.zone), 0, 2))
  service_account = var.service_account == null ? null : {
    email = (
      var.service_account.auto_create
      ? google_service_account.service_account[0].email
      : var.service_account.email
    )
    scopes = (
      var.service_account.scopes != null ? var.service_account.scopes : (
        var.service_account.email == null && !var.service_account.auto_create
        # default scopes for Compute default SA
        ? [
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring.write"
        ]
        # default scopes for own SA
        : [
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/userinfo.email"
        ]
      )
    )
  }
  tags_combined = (
    var.tag_bindings == null && var.tag_bindings_firewall == null
    ? null
    : merge(
      coalesce(var.tag_bindings, {}),
      coalesce(var.tag_bindings_firewall, {})
    )
  )
  termination_action = (
    var.options.spot ? coalesce(var.options.termination_action, "STOP") : null
  )
}