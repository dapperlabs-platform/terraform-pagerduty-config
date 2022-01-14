terraform {
  required_version = ">= 1"
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.14.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = ">= 2.2.1"
    }
  }
}
