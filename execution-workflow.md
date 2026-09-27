## Execution Workflow

The deployment follows a Blue/Green workflow where the existing BLUE environment remains active while CodeDeploy prepares the GREEN environment.

### 1. Prepare Artifacts

Upload the deployment packages to the versioned S3 bucket:

```text
app-blue.zip
app-green.zip
```

Each package contains `appspec.yml`, `index.html`, and `health.html`.

### 2. Deploy GREEN

Create a new CodeDeploy deployment using:

```text
s3://<bucket-name>/app-green.zip
```

### 3. Create Replacement Fleet

CodeDeploy automatically creates a replacement Auto Scaling group based on `blue-asg` and launches the GREEN instances.

### 4. Validate Instances

The new instances are registered with `blue-tg` and validated using the health check:

```text
/health.html
```

Expected response:

```text
OK
```

### 5. Shift Traffic

Once the GREEN instances are healthy, CodeDeploy reroutes production traffic through the ALB to the new instances.

```text
ALB
 │
 ▼
GREEN Instances
```

### 6. Terminate BLUE

The original BLUE instances remain available during the configured termination wait period. After the wait period, they are terminated if the deployment completes successfully.

### 7. Rollback

If required while the original instances are still available, the deployment can be stopped and rolled back to the BLUE environment.

### 8. Cleanup

After testing, remove the CodeDeploy resources, Auto Scaling groups, EC2 instances, ALB, target group, S3 bucket, IAM roles, security groups, and VPC resources.
