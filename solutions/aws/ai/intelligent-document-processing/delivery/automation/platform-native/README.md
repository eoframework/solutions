# Platform-Native Deployment

This solution uses **Terraform** for infrastructure deployment. Platform-native tooling (AWS CloudFormation, SAM, CDK) is not currently implemented.

## Recommended Approach

Use the Terraform deployment in the `terraform/` directory:

```bash
cd ../terraform/environments/prod
terraform init
terraform plan
terraform apply
```

## Available Environments

- **prod**: Production environment with full features
- **test**: Testing environment with reduced capacity
- **dr**: Disaster Recovery environment (passive standby)

## Why Terraform?

1. **Multi-cloud portable**: Same patterns work across AWS, Azure, GCP
2. **State management**: Built-in remote state with locking
3. **Module reuse**: EO Framework modules are Terraform-based
4. **CI/CD integration**: Works with GitHub Actions, GitLab CI, etc.

## Future Platform-Native Options

If platform-native deployment is required in the future, consider:

- **AWS SAM**: For Lambda-centric deployments
- **AWS CDK**: For TypeScript/Python infrastructure code
- **CloudFormation**: For AWS-native templates

See the [EO Framework documentation](../../../../../../docs/) for more details on supported deployment methods.
