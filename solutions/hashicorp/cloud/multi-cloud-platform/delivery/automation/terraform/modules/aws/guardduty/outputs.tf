#------------------------------------------------------------------------------
# AWS GuardDuty Module Outputs
#------------------------------------------------------------------------------

output "detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "account_id" {
  description = "AWS account ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.account_id
}
