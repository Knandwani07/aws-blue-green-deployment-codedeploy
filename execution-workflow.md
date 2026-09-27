## Execution Workflow

The execution follows a Blue/Green workflow where the existing **BLUE** environment remains active while CodeDeploy prepares and validates the replacement **GREEN** environment.

### 1. Prepare Deployment Artifact

Upload the GREEN deployment package to the versioned S3 bucket:

```text
app-green.zip
```

The package contains:

```text
appspec.yml
index.html
health.html
```

### 2. Start Deployment

Create a CodeDeploy deployment using the GREEN revision stored in S3.

```text
S3
 │
 ▼
CodeDeploy
```

### 3. Create Replacement Fleet

CodeDeploy automatically creates a replacement Auto Scaling group based on the existing `blue-asg` and launches new EC2 instances. 

```text
CodeDeploy
     │
     ▼
Replacement ASG
     │
     ▼
New EC2 Instances
```

### 4. Validate Instances

The new instances are registered with the production target group and validated using the health check:

```text
/health.html
```

The expected response is:

```text
OK
```

### 5. Shift Traffic

After the replacement instances are healthy, CodeDeploy reroutes production traffic to the new instances through the Application Load Balancer. 

```text
New EC2 Instances
       │
       ▼
     blue-tg
       │
       ▼
Traffic Shift
       │
       ▼
GREEN Production
```

### 6. Terminate BLUE

The original BLUE instances remain available during the configured termination wait period. After the wait period, they are terminated if the deployment completes successfully. 

### 7. Rollback

If required while the original instances are still running, the deployment can be stopped and rolled back to the BLUE environment. 

### 8. Cleanup

After testing, delete the AWS resources created for the project, including CodeDeploy resources, Auto Scaling groups, EC2 instances, ALB, target group, S3 bucket, IAM roles, security groups, and VPC resources. 
