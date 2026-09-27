## CodeDeployBlueGreenASG Policy

This inline IAM policy is attached to the `CodeDeployServiceRole` and provides permissions required during the Blue/Green deployment process.

## Permissions

### `ec2:RunInstances`

Allows CodeDeploy to launch EC2 instances for the replacement Auto Scaling group during a Blue/Green deployment.

### `ec2:CreateTags`

Allows CodeDeploy to create tags on the EC2 resources it launches.

### `iam:PassRole`

Allows CodeDeploy to pass the required IAM role to the EC2 instances it launches.

## Policy Summary

```text
CodeDeploy
    │
    ├── RunInstances → Launch replacement EC2 instances
    ├── CreateTags   → Tag launched resources
    └── PassRole     → Attach/pass the required IAM role
