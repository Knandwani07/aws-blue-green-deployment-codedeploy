## Deployment Guide

This guide walks through the complete setup and deployment of the AWS Blue/Green deployment project using **Amazon S3, IAM, VPC, EC2, Auto Scaling, Application Load Balancer, and AWS CodeDeploy**. The project uses the Mumbai (`ap-south-1`) Region. 

## Prerequisites

Before starting, make sure you have:

* An AWS account with permissions to create IAM, VPC, EC2, ALB, Auto Scaling, CodeDeploy, and S3 resources.
* Basic knowledge of AWS networking and load balancing.
* A web browser for testing the ALB endpoint.
* The following deployment packages:

  * `app-blue.zip`
  * `app-green.zip`
* Each ZIP must contain `appspec.yml`, `index.html`, and `health.html` at the ZIP root. 

## Step 1: Create the S3 Artifact Bucket

Create an S3 bucket for the deployment artifacts.

Configure:

* Bucket name: `<your-bucket-name>`
* Block Public Access: Enabled
* Versioning: Enabled
* Default encryption: SSE-S3

Upload:

```text
app-blue.zip
app-green.zip
```

Keep the object Version IDs available for reference. 

## Step 2: Create IAM Roles

### CodeDeploy Service Role

Create an IAM role with:

```text
Trusted entity: AWS Service
Use case: CodeDeploy
Role name: CodeDeployServiceRole
Policy: AWSCodeDeployRole
```

Add the following inline policy and name it `CodeDeployBlueGreenASG`:

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

### EC2 Instance Role

Create a second role:

```text
Trusted entity: AWS Service
Use case: EC2
Role name: EC2CodeDeployInstanceProfile
```

Attach:

```text
AmazonS3ReadOnlyAccess
AmazonSSMManagedInstanceCore
```



## Step 3: Create the VPC

Create a VPC using **VPC and more**.

Configure:

```text
Name: blue-green-deployment
IPv4 CIDR: 10.0.0.0/16
Availability Zones: 2
Public subnets: 2
Private subnets: 0
NAT gateways: None
VPC endpoints: None
```

The resulting public subnets should be in two Availability Zones.

For the documented Mumbai setup:

```text
blue-green-deployment-subnet-public1-ap-south-1a
blue-green-deployment-subnet-public2-ap-south-1b
```

Verify that **Auto-assign public IPv4 address** is enabled for both subnets. 

## Step 4: Create Security Groups

### ALB Security Group

Create:

```text
Name: alb-sg
VPC: blue-green-deployment-vpc
```

Inbound:

```text
HTTP | Port 80 | Source: 0.0.0.0/0
```

### EC2 Security Group

Create:

```text
Name: web-app-sg
VPC: blue-green-deployment-vpc
```

Inbound:

```text
HTTP | Port 80 | Source: alb-sg
```

This allows the ALB to reach the EC2 instances while restricting direct HTTP access to the instances. 

## Step 5: Create the Target Group and ALB

### Create Target Group

Create:

```text
Name: blue-tg
Target type: Instances
Protocol: HTTP
Port: 80
Health check path: /health.html
VPC: blue-green-deployment-vpc
```



### Create Application Load Balancer

Configure:

```text
Name: app-alb
Scheme: Internet-facing
VPC: blue-green-deployment-vpc
Listener: HTTP : 80
Security Group: alb-sg
```

Select both public subnets and configure the default action to forward traffic to:

```text
blue-tg
```



## Step 6: Create the Launch Template

Create:

```text
Name: web-app-lt
AMI: Amazon Linux 2023
Instance type: t2.micro
Security Group: web-app-sg
IAM Instance Profile: EC2CodeDeployInstanceProfile
```

Add the following user data:

```bash
#!/bin/bash

dnf install -y httpd ruby wget

systemctl enable httpd
systemctl start httpd

echo "BLUE" > /var/www/html/index.html
echo "OK" > /var/www/html/health.html

cd /tmp
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
```

The user data installs Apache and the CodeDeploy agent and creates the initial BLUE application and health-check files. 

## Step 7: Create the Blue Auto Scaling Group

Create:

```text
Name: blue-asg
Launch Template: web-app-lt
```

Select both public subnets.

Under load balancing:

```text
Attach to an existing load balancer
Target group: blue-tg
ELB health checks: Enabled
```

Configure capacity:

```text
Desired: 2
Minimum: 2
Maximum: 4
```

After creation, verify that the instances register as **Healthy** in `blue-tg`.

Open the ALB DNS name in a browser and verify that the **BLUE** page is displayed. 

## Step 8: Create the CodeDeploy Application

Create an AWS CodeDeploy application:

```text
Application name: bluegreen-codedeploy-app
Compute platform: EC2/On-Premises
```

Then create the deployment group:

```text
Deployment group: app-dg
Service role: CodeDeployServiceRole
Deployment type: Blue/green
```

For the environment configuration:

```text
Automatically copy Amazon EC2 Auto Scaling group
Source ASG: blue-asg
```

Configure:

```text
Traffic rerouting: Reroute traffic immediately
Instance termination: Terminate original instances after 10 minutes
```

For the load balancer:

```text
Load balancer: app-alb
Production target group: blue-tg
```

Then create the deployment group. 

## Step 9: Deploy the GREEN Revision

Open the `app-dg` deployment group and select **Create deployment**.

Configure:

```text
Revision type: My application is stored in Amazon S3
Revision location: s3://<your-bucket-name>/app-green.zip
File type: .zip
```

Start the deployment. 

## Step 10: Monitor the Deployment

During deployment, CodeDeploy creates a replacement Auto Scaling group based on `blue-asg`.

The replacement group follows a name similar to:

```text
CodeDeploy_app-dg_d-XXXXXXXXX
```

The new instances are launched and registered with the target group.

Monitor the deployment through stages such as:

```text
Provisioning
      ↓
Installing
      ↓
Registering with load balancer
      ↓
Traffic rerouting
```



## Step 11: Verify GREEN

Refresh the ALB DNS endpoint.

The application should now display:

```text
GREEN
```

Verify:

* GREEN instances are healthy.
* Replacement instances are registered with `blue-tg`.
* Original instances are being deregistered or draining.
* The replacement Auto Scaling group exists.
* CodeDeploy reports the deployment progress correctly. 

## Step 12: Roll Back if Required

While the original BLUE instances are still available during the termination wait period, open the running deployment.

Select:

```text
Stop deployment
```

If available, choose:

```text
Stop and roll back deployment
```

Refresh the ALB endpoint and verify that the application returns to:

```text
BLUE
```

A redeployment of `app-blue.zip` is different from a rollback because it starts a new Blue/Green deployment cycle. 

## Step 13: Clean Up Resources

After completing the deployment, remove the resources created for the project.

Recommended cleanup order:

```text
CodeDeploy application and deployment group
        ↓
Auto Scaling groups
        ↓
EC2 instances
        ↓
Launch template
        ↓
Application Load Balancer + target group
        ↓
Security groups
        ↓
S3 bucket
        ↓
IAM roles
        ↓
VPC and associated resources
```

Verify that the CodeDeploy-created replacement ASG and all associated EC2 instances have also been removed. 

## Deployment Result

The completed workflow demonstrates:

```text
BLUE Application
       │
       ▼
CodeDeploy
       │
       ▼
Replacement GREEN Fleet
       │
       ▼
Health Checks
       │
       ▼
Traffic Shift
       │
       ▼
GREEN Application
       │
       ▼
BLUE Termination / Rollback Window
```

The deployment provides a repeatable Blue/Green release workflow using versioned S3 artifacts, EC2 Auto Scaling, ALB health checks, and AWS CodeDeploy. 
