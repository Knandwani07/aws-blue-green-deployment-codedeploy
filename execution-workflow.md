## Execution Workflow

The project uses AWS CodeDeploy Blue/Green deployment to introduce a new application version while the existing environment continues serving traffic during the deployment process.

## Initial Environment

```text
Users
  ↓
Internet Gateway
  ↓
Application Load Balancer
  ↓
blue-tg
  ↓
BLUE EC2 Instances
````

The BLUE instances are managed by:

```text
blue-asg
```

The ALB checks:

```text
/health.html
```

Expected response:

```text
OK
```

## Deployment Execution

```text
app-green.zip
      ↓
     S3
      ↓
 CodeDeploy
      ↓
Replacement ASG
      ↓
GREEN EC2 Instances
      ↓
Deployment Hooks
      ↓
Health Checks
      ↓
blue-tg
      ↓
Traffic Shift
      ↓
GREEN Production
```

## Step 1: Store the Revision

The GREEN application package is uploaded to S3:

```text
app-green.zip
```

The package contains:

```text
appspec.yml
index.html
health.html
```

`appspec.yml` must be at the root of the ZIP.

## Step 2: Start the Deployment

The deployment is created from:

```text
s3://<your-bucket-name>/app-green.zip
```

CodeDeploy uses the `app-dg` deployment group.

## Step 3: Create the Replacement Fleet

CodeDeploy copies the configuration of `blue-asg` and creates a replacement Auto Scaling group.

Example:

```text
blue-asg
    ↓
CodeDeploy
    ↓
CodeDeploy_app-dg_d-XXXXXXXXX
```

The replacement ASG launches the new EC2 instances.

## Step 4: Install the GREEN Revision

CodeDeploy installs the GREEN revision on the new instances.

The deployment progresses through stages such as:

```text
Provisioning
      ↓
Installing
      ↓
Registering
```

## Step 5: Register the GREEN Instances

The replacement instances are registered with:

```text
blue-tg
```

The ALB then performs health checks against:

```text
/health.html
```

Expected response:

```text
OK
```

## Step 6: Shift Traffic

Once the GREEN instances are healthy, CodeDeploy shifts production traffic to them.

Before:

```text
ALB
 ↓
blue-tg
 ├── BLUE
 └── BLUE
```

After:

```text
ALB
 ↓
blue-tg
 ├── GREEN
 └── GREEN
```

The target group remains `blue-tg`; the instances serving traffic change.

## Step 7: Verify GREEN

Open the same ALB DNS endpoint.

Expected result:

```text
GREEN
CURRENTLY SERVING TRAFFIC
```

This demonstrates that traffic has moved from the original BLUE environment to the GREEN environment.

## Step 8: Termination Wait

After traffic is shifted, the original BLUE instances remain available for the configured termination wait period.

```text
GREEN
  ↓
Serving production traffic

BLUE
  ↓
Temporarily retained
```

After the wait period:

```text
BLUE instances
      ↓
Terminated
```

GREEN continues serving production traffic.

## Step 9: Rollback Path

If a problem is identified before the original BLUE instances are terminated:

```text
GREEN
  ↓
Stop deployment
  ↓
Stop and roll back deployment
  ↓
BLUE
```

The ALB endpoint should then return the BLUE application.

## Step 10: New Deployment of BLUE

If the rollback window has passed, deploying the previous version again is a new deployment:

```text
app-blue.zip
     ↓
CodeDeploy
     ↓
New Blue/Green Deployment
```

It should not be treated as the same rollback operation.

## Complete Workflow

```text
                    ┌──────────────────┐
                    │   app-green.zip  │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │       S3         │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │    CodeDeploy    │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Replacement ASG  │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │  GREEN Instances │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │  Health Checks   │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │     blue-tg      │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │  Traffic Shift   │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ GREEN Production │
                    └────────┬─────────┘
                             ↓
                  Termination Wait Period
                             ↓
                   ┌─────────┴─────────┐
                   ↓                   ↓
                Rollback            Complete
                   ↓                   ↓
                 BLUE                GREEN
```

