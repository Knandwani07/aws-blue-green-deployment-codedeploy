## Deployment Guide

This guide walks through the complete AWS Blue/Green deployment setup using Amazon S3, IAM, VPC, EC2, Auto Scaling, Application Load Balancer, and AWS CodeDeploy.

> **Note:** This guide uses the Mumbai (`ap-south-1`) AWS Region. If you use another Region, update the Region-specific values accordingly.

## Prerequisites

Before starting, make sure you have:

- An AWS account with the required permissions.
- Basic knowledge of AWS VPC, EC2, ALB, Auto Scaling, IAM, and CodeDeploy.
- `app-blue.zip` and `app-green.zip`.
- The EC2 user-data script.
- The `CodeDeployBlueGreenASG` inline IAM policy.

## Step I: Create the S3 Artifact Bucket

1. Open **Amazon S3**.
2. Click **Create bucket**.
3. Configure:

```text
Bucket Name: <your-bucket-name>
Block Public Access: Enabled
Bucket Versioning: Enabled
Default Encryption: SSE-S3
````

4. Create the bucket.
5. Upload:

```text
app-blue.zip
app-green.zip
```

6. Keep both files at the bucket root.
7. Note the object Version IDs.

## Step II: Create IAM Roles

### CodeDeploy Service Role

1. Open **IAM → Roles → Create role**.
2. Select **AWS Service**.
3. Select **CodeDeploy** as the use case.
4. Name the role:

```text
CodeDeployServiceRole
```

5. Attach:

```text
AWSCodeDeployRole
```

6. Create the role.

### Add the Blue/Green ASG Policy

Add the following inline policy to `CodeDeployServiceRole`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateTags",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

Name it:

```text
CodeDeployBlueGreenASG
```

### EC2 Instance Role

Create an EC2 role:

```text
EC2CodeDeployInstanceProfile
```

Attach:

```text
AmazonS3ReadOnlyAccess
AmazonSSMManagedInstanceCore
```

## Step III: Create the VPC

1. Open **VPC → Your VPCs**.
2. Select **Create VPC → VPC and more**.
3. Configure:

```text
Name: blue-green-deployment
IPv4 CIDR: 10.0.0.0/16

Availability Zones: 2
Public Subnets: 2
Private Subnets: 0

NAT Gateways: None
VPC Endpoints: None
```

4. Create the VPC.

For the documented setup, the public subnets are:

```text
blue-green-deployment-subnet-public1-ap-south-1a
blue-green-deployment-subnet-public2-ap-south-1b
```

Verify that **Auto-assign public IPv4 address** is enabled for both public subnets.

## Step IV: Create Security Groups

### ALB Security Group

Create:

```text
Name: alb-sg
```

Inbound rule:

```text
HTTP | Port 80 | Source: 0.0.0.0/0
```

### EC2 Security Group

Create:

```text
Name: web-app-sg
```

Inbound rule:

```text
HTTP | Port 80 | Source: alb-sg
```

Leave the default outbound rules enabled.

## Step V: Create the Target Group

1. Open **EC2 → Target Groups**.
2. Click **Create target group**.
3. Configure:

```text
Name: blue-tg
Target Type: Instances
Protocol: HTTP
Port: 80
VPC: blue-green-deployment
Health Check Path: /health.html
```

4. Create the target group.

## Step VI: Create the Application Load Balancer

1. Open **EC2 → Load Balancers**.
2. Click **Create Load Balancer**.
3. Select **Application Load Balancer**.
4. Configure:

```text
Name: app-alb
Scheme: Internet-facing
```

5. Select the two public subnets.
6. Select:

```text
Security Group: alb-sg
Listener: HTTP : 80
Default Action: Forward to blue-tg
```

7. Create the load balancer.

## Step VII: Create the Launch Template

1. Open **EC2 → Launch Templates**.
2. Click **Create launch template**.
3. Configure:

```text
Name: web-app-lt
AMI: Amazon Linux 2023
Instance Type: t2.micro
Security Group: web-app-sg
IAM Instance Profile: EC2CodeDeployInstanceProfile
```

4. Add the user-data script:

```bash
#!/bin/bash

dnf install -y httpd ruby wget

systemctl enable httpd
systemctl start httpd

cd /tmp
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
```

5. Create the launch template.

## Step VIII: Create the BLUE Auto Scaling Group

1. Open **EC2 → Auto Scaling Groups**.
2. Click **Create Auto Scaling group**.
3. Configure:

```text
Name: blue-asg
Launch Template: web-app-lt
VPC: blue-green-deployment
```

4. Select both public subnets.
5. Under load balancing, select:

```text
Attach to an existing load balancer
Target Group: blue-tg
```

6. Enable **ELB health checks**.
7. Configure:

```text
Desired Capacity: 2
Minimum Capacity: 2
Maximum Capacity: 4
```

8. Create the Auto Scaling group.
9. Verify that the EC2 instances become healthy in `blue-tg`.

Open the ALB DNS name and verify that the BLUE application is displayed.

## Step IX: Create the CodeDeploy Application

1. Open **AWS CodeDeploy → Applications**.
2. Click **Create application**.
3. Configure:

```text
Application Name: bluegreen-codedeploy-app
Compute Platform: EC2/On-Premises
```

4. Create the application.

## Step X: Create the Deployment Group

Create a deployment group:

```text
Deployment Group Name: app-dg
Service Role: CodeDeployServiceRole
Deployment Type: Blue/green
```

For the environment configuration, select:

```text
Automatically copy Amazon EC2 Auto Scaling group
Source Auto Scaling Group: blue-asg
```

For traffic configuration:

```text
Reroute traffic: Immediately
```

For instance termination, configure the required termination wait period after a successful deployment.

For load balancing:

```text
Load Balancer: app-alb
Production Target Group: blue-tg
```

Create the deployment group.

## Step XI: Deploy the GREEN Revision

1. Open `app-dg`.
2. Click **Create deployment**.
3. Select:

```text
Revision Type:
My application is stored in Amazon S3

Revision Location:
s3://<your-bucket-name>/app-green.zip

File Type:
.zip
```

4. Click **Create deployment**.

## Step XII: Monitor the Deployment

CodeDeploy creates a replacement Auto Scaling group similar to:

```text
CodeDeploy_app-dg_d-XXXXXXXXX
```

The replacement instances receive the GREEN revision.

Monitor the deployment through:

```text
Provisioning
→ Installing
→ Registering with load balancer
```

The new instances are registered with `blue-tg`.

## Step XIII: Verify the Traffic Shift

Once the replacement instances become healthy:

1. Open the ALB DNS name.
2. Refresh the page.
3. Verify that the GREEN application is displayed.
4. Verify that the replacement instances are healthy.
5. Verify that the original BLUE instances are draining or deregistered.

Expected result:

```text
GREEN
CURRENTLY SERVING TRAFFIC
```

## Step XIV: Roll Back if Required

The original BLUE instances remain available during the configured termination wait period.

If rollback is required while they are still available:

1. Open the running deployment.
2. Click **Stop deployment**.
3. Select **Stop and roll back deployment**, if available.
4. Refresh the ALB endpoint.
5. Verify that BLUE is serving traffic again.

```text
GREEN
   ↓
Rollback
   ↓
BLUE
```

If the original instances have already been terminated, use a new deployment with `app-blue.zip` instead of describing the operation as a rollback.

## Step XV: Verify the Deployment

Confirm:

* GREEN instances are healthy.
* GREEN is serving traffic through the ALB.
* The deployment completes successfully.
* The replacement Auto Scaling group was created by CodeDeploy.
* The original instances are terminated after the configured wait period.

The deployment flow is:

```text
BLUE
 ↓
CodeDeploy
 ↓
Replacement ASG
 ↓
GREEN Instances
 ↓
Health Checks
 ↓
Traffic Shift
 ↓
GREEN
```
