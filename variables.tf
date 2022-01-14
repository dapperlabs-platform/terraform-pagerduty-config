variable "teams" {
  type        = map(any)
  description = <<EOT
  Key/Value pairs of PagerDuty Team names => Team and Service configuration.
  {
    # Name of a team to be created
    "SRE" = {
      # Name of an existing team
      parent_name = ""
      # Email of an existing user (required)
      manager = ""
      escalation_policy = {
        num_loops                   = 2
        escalation_delay_in_minutes = 10
      }
      services = {
        "Generic Infrastructure" = {
          auto_resolve_timeout    = 14400
          acknowledgement_timeout = 600
          alert_creation          = "create_alerts_and_incidents"
        }
      }
      # List of existing user emails (required)
      responders = []
    }
  }
EOT
}
