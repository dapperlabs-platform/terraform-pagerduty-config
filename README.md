# PagerDuty and Grafana Configuration

Creates a PagerDuty team, services owned by the team and provisions an initial schedule with provided responders.
Creates Grafana Notification Channels for each Team/Service and outputs their UIDs to be consumed by Grafana Dashboard modules.

`make` updates the `README.md` file based on Terraform changes.

## Requires

1. `terraform` [Download](https://www.terraform.io/downloads.html) [Brew](https://formulae.brew.sh/formula/terraform)
2. `terraform-docs` to update the README. [Download](https://github.com/terraform-docs/terraform-docs) [Brew](https://formulae.brew.sh/formula/terraform-docs)
3. `make` to update the README. [Download](https://www.gnu.org/software/make/)

## Usage

```hcl
module "pagerduty_grafana_config" {
    source = "github.com/dapperlabs-platform/terraform-pagerduty-grafana-config.git?ref=vX.Y.Z"
    teams = {
        "SRE" = {
        parent_name = "Product Team"
        manager = "manager@company.com"
        escalation_policy = {
            num_loops                   = 2
            escalation_delay_in_minutes = 10
        }
        services = {
            "Infrastructure" = {
                auto_resolve_timeout    = 14400
                acknowledgement_timeout = 600
                alert_creation          = "create_alerts_and_incidents"
            }
            "CI/CD Runners" = {
                auto_resolve_timeout    = 14400
                acknowledgement_timeout = 600
                alert_creation          = "create_alerts_and_incidents"
            }
        }
        responders = [
            "alice@company.com",
            "bob@company.com"
        ]
    }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.14.0 |
| <a name="requirement_pagerduty"></a> [pagerduty](#requirement\_pagerduty) | >= 2.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | >= 1.14.0 |
| <a name="provider_pagerduty"></a> [pagerduty](#provider\_pagerduty) | >= 2.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [grafana_alert_notification.pagerduty_services](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/alert_notification) | resource |
| [pagerduty_escalation_policy.escalation_policies](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/escalation_policy) | resource |
| [pagerduty_schedule.schedules](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/schedule) | resource |
| [pagerduty_service.services](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/service) | resource |
| [pagerduty_service_integration.integrations](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/service_integration) | resource |
| [pagerduty_team.teams](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/team) | resource |
| [pagerduty_team_membership.responders](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/resources/team_membership) | resource |
| [pagerduty_team.parents](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/data-sources/team) | data source |
| [pagerduty_user.users](https://registry.terraform.io/providers/pagerduty/pagerduty/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_teams"></a> [teams](#input\_teams) | Key/Value pairs of PagerDuty Team names => Team and Service configuration.<br>  {<br>    # Name of a team to be created<br>    "SRE" = {<br>      # Name of an existing team<br>      parent\_name = ""<br>      # Email of an existing user (required)<br>      manager = ""<br>      escalation\_policy = {<br>        num\_loops                   = 2<br>        escalation\_delay\_in\_minutes = 10<br>      }<br>      services = {<br>        "Generic Infrastructure" = {<br>          auto\_resolve\_timeout    = 14400<br>          acknowledgement\_timeout = 600<br>          alert\_creation          = "create\_alerts\_and\_incidents"<br>        }<br>      }<br>      # List of existing user emails (required)<br>      responders = []<br>    }<br>  } | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_notification_channels"></a> [grafana\_notification\_channels](#output\_grafana\_notification\_channels) | Grafana notification channel IDs for Team/Service combinations |
