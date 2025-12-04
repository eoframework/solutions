#------------------------------------------------------------------------------
# TFE Team Module Outputs
#------------------------------------------------------------------------------

output "team_ids" {
  description = "Map of team names to IDs"
  value       = { for k, v in tfe_team.team : k => v.id }
}

output "team_names" {
  description = "List of team names"
  value       = [for k, v in tfe_team.team : v.name]
}

output "admin_team_id" {
  description = "Admin team ID"
  value       = tfe_team.team["admins"].id
}

output "operator_team_id" {
  description = "Operator team ID"
  value       = tfe_team.team["operators"].id
}

output "developer_team_id" {
  description = "Developer team ID"
  value       = tfe_team.team["developers"].id
}
