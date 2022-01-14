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
