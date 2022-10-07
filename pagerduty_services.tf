locals {
  # Creates a string array containing "team name/service name" entries that should match the service
  # ID used in pagerduty_service.services
  service_names = toset(flatten([
    for team in local.team_names : [
      for name, value in var.teams[team].services : "${team}/${name}"
    ]
  ]))
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/service
resource "pagerduty_service" "services" {
  # Create an array of service config objects, iterate through it and return an id => config map
  for_each = { for service in flatten([
    for team in local.team_names : [
      for name, config in var.teams[team].services : {
        id   = "${team}/${name}"
        team = team,
        service = {
          name   = name
          config = config
        }
    }]]) :
    service.id => service
  }

  name                    = each.value.service.name
  escalation_policy       = pagerduty_escalation_policy.escalation_policies[each.value.team].id
  auto_resolve_timeout    = try(each.value.service.config.auto_resolve_timeout, 14400)
  acknowledgement_timeout = try(each.value.service.config.acknowledgement_timeout, 600)
  alert_creation          = try(each.value.service.config.alert_creation, "create_alerts_and_incidents")
}

resource "pagerduty_service_integration" "integrations" {
  for_each = local.service_names

  name    = "${each.value} Generic API Service Integration"
  type    = "generic_events_api_inbound_integration"
  service = pagerduty_service.services[each.value].id
}
