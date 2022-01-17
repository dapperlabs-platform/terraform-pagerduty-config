locals {
  team_names = toset(keys(var.teams))
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/data-sources/team
data "pagerduty_team" "parents" {
  # filter out teams that do not provide a parent
  for_each = { for k, v in var.teams : k => v if try(v.parent_name, "") != "" }

  name = each.value.parent_name
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/team
resource "pagerduty_team" "teams" {
  for_each = local.team_names

  name   = each.value
  parent = try(data.pagerduty_team.parents[each.value].id, null)
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/data-sources/user
data "pagerduty_user" "users" {
  # [["user1", "user2"], "manager1", ["user3", "user4"], "manager2"] -> ["user1", "user2", "user3", "user4", "manager1", "manager2"]
  for_each = toset(flatten([for v in values(var.teams) : [v.responders, v.manager]]))

  email = each.value
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/team_membership
resource "pagerduty_team_membership" "responders" {
  for_each = {
    for membership in flatten(
      [for k, v in var.teams : [
        for email in v.responders : { team_name = k, email = email }
      ]]
    ) : "${membership.team_name}/${membership.email}" => membership
  }

  user_id = data.pagerduty_user.users[each.value.email].id
  team_id = pagerduty_team.teams[each.value.team_name].id
  role    = "responder"
}

# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/schedule
# Default schedule that is ignored by terraform after creation to allow managers to 
# modify it using the PagerDuty UI
resource "pagerduty_schedule" "schedules" {
  for_each = local.team_names

  name      = "${each.value} Daily Rotation"
  time_zone = "Etc/UTC"

  layer {
    name                   = "Daily Shift"
    start                  = "2022-01-01T00:00:00Z"
    rotation_virtual_start = "2022-01-01T00:00:00Z"
    # 24 hours in seconds
    rotation_turn_length_seconds = 86400
    users = [
      for user in data.pagerduty_user.users : user.id if contains(var.teams[each.value].responders, user.email)
    ]
  }

  teams = [
    pagerduty_team.teams[each.value].id
  ]

  lifecycle {
    # Ignore manual schedule tweaking in the UI
    ignore_changes = all
  }
}


# https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs/resources/escalation_policy
resource "pagerduty_escalation_policy" "escalation_policies" {
  for_each = local.team_names

  name      = "${each.value} Escalation Policy"
  num_loops = try(var.teams[each.value].escalation_policy.num_loops, 2)
  teams = [
    pagerduty_team.teams[each.value].id
  ]

  rule {
    escalation_delay_in_minutes = try(var.teams[each.value].escalation_policy.escalation_delay_in_minutes, 10)

    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.schedules[each.value].id
    }

    target {
      type = "user_reference"
      id   = data.pagerduty_user.users[var.teams[each.value].manager].id
    }
  }
}

