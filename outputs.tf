output "grafana_notification_channels" {
  description = "Grafana notification channel IDs for Team/Service combinations"
  value = {
    for service in local.service_names : service => grafana_alert_notification.pagerduty_services[service].uid
  }
}
