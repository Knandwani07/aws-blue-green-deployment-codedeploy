## Cleanup Guide

After completing the Blue/Green deployment test, remove the AWS resources created for the project to avoid unnecessary charges.

> **Important:** If a deployment is still running, stop or roll back the deployment before starting the cleanup. 

## Cleanup Order

Follow this order to avoid dependencies between resources.

### 1. Delete CodeDeploy Resources

Delete:

```text
bluegreen-codedeploy-app
└── app-dg
```

Make sure there is no active deployment before deleting the application and deployment group.

### 2. Delete Auto Scaling Groups

Delete:

```text
blue-asg
```

Also check for the CodeDeploy-created replacement Auto Scaling group:

```text
CodeDeploy_app-dg_d-XXXXXXXXX
```

Delete it if it still exists.

### 3. Verify EC2 Instances

After deleting the Auto Scaling groups, verify that all associated EC2 instances have been terminated.

Check for both:

* Original BLUE instances
* CodeDeploy-created replacement instances

### 4. Delete the Launch Template

Delete:

```text
web-app-lt
```

### 5. Delete the Load Balancer and Target Group

Delete the Application Load Balancer:

```text
app-alb
```

Then delete the target group:

```text
blue-tg
```

### 6. Delete Security Groups

Delete the security groups created for the project:

```text
web-app-sg
alb-sg
```

Delete `web-app-sg` before `alb-sg` if there is still a dependency between them.

### 7. Empty and Delete the S3 Bucket

The bucket contains the deployment artifacts:

```text
app-blue.zip
app-green.zip
```

Because bucket versioning was enabled, make sure the bucket is completely emptied, including object versions, before deleting the bucket.

Then delete the S3 bucket.

### 8. Delete IAM Roles

Delete the IAM roles created for the project:

```text
CodeDeployServiceRole
EC2CodeDeployInstanceProfile
```

The `CodeDeployBlueGreenASG` inline policy is removed when its associated role is deleted.

### 9. Delete the VPC

After all dependent resources have been removed, delete the VPC:

```text
blue-green-deployment-vpc
```

Also verify that its associated subnets, route tables, and Internet Gateway are removed as required.

### 10. Final Verification

Before finishing, verify that no project resources remain:

```text
CodeDeploy
    ↓
Auto Scaling Groups
    ↓
EC2 Instances
    ↓
Launch Template
    ↓
ALB + Target Group
    ↓
Security Groups
    ↓
S3 Bucket
    ↓
IAM Roles
    ↓
VPC Resources
```

The documentation specifically recommends verifying that no related resources remain after cleanup. 
