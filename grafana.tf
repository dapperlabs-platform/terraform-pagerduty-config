resource "grafana_alert_notification" "pagerduty_services" {
  for_each = local.service_names

  name = "${each.value} PagerDuty Service"
  type = "pagerduty"
  settings = {
    autoResolve    = true
    uploadImage    = "true"
    httpMethod     = "POST"
    severity       = "critical"
    integrationKey = sensitive(pagerduty_service_integration.integrations[each.value].integration_key)
  }
  lifecycle {
    ignore_changes = [
      secure_settings
    ]
  }
}
