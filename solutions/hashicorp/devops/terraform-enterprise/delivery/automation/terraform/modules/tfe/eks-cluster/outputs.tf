#------------------------------------------------------------------------------
# EKS Cluster Module Outputs
#------------------------------------------------------------------------------

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.tfe.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.tfe.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.tfe.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.cluster.id
}

output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.tfe.node_group_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.tfe.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.tfe.dns_name
}
