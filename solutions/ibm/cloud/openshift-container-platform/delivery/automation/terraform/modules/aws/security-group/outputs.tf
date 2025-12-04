#------------------------------------------------------------------------------
# AWS Security Group Module Outputs
#------------------------------------------------------------------------------

output "control_plane_security_group_id" {
  description = "Control plane security group ID"
  value       = aws_security_group.control_plane.id
}

output "worker_security_group_id" {
  description = "Worker node security group ID"
  value       = aws_security_group.worker.id
}

output "lb_security_group_id" {
  description = "Load balancer security group ID"
  value       = aws_security_group.lb.id
}
