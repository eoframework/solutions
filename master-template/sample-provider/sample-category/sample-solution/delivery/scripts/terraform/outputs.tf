# Sample Terraform Outputs
# Define output values for your solution

output "resource_id" {
  description = "ID of the created resource"
  value       = sample_resource.example.id
}

output "resource_name" {
  description = "Name of the created resource"
  value       = sample_resource.example.name
}

# Add your outputs here