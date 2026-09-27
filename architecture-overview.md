## Architecture Overview

This project implements a **Blue/Green deployment architecture on AWS** using AWS CodeDeploy, EC2 Auto Scaling, an Application Load Balancer, and Amazon S3.

The architecture maintains the current production environment (**BLUE**) while CodeDeploy provisions a replacement environment for the new application version (**GREEN**). After the replacement instances pass health checks, traffic is shifted to the new version.

The project is deployed in the **Mumbai (`ap-south-1`) AWS Region**.

## Architecture Diagram

<img width="1536" height="1024" alt="Blue-Green-architecture-Diagram" src="https://github.com/user-attachments/assets/9cc990c2-85a6-49a7-b4ab-9b4cfe7dc24f" />

## AWS Components

* **Amazon VPC** — Provides the network environment across two Availability Zones.
* **Application Load Balancer** — Receives HTTP traffic and routes requests to healthy instances.
* **Blue Auto Scaling Group** — Runs the current production instances.
* **CodeDeploy Replacement ASG** — Created automatically during the Blue/Green deployment.
* **EC2 Instances** — Run Apache, the application, and the CodeDeploy agent.
* **Amazon S3** — Stores the `app-blue.zip` and `app-green.zip` deployment packages.
* **AWS CodeDeploy** — Creates the replacement fleet, deploys the new version, and manages traffic shifting.
* **IAM** — Provides permissions for CodeDeploy and EC2.
* **Security Groups** — Restrict traffic between the ALB and EC2 instances.

## Traffic Flow

```text
User
  │
  ▼
Application Load Balancer
  │
  ▼
blue-tg
  │
  ├── BLUE EC2
  └── BLUE EC2
```

The ALB uses `/health.html` to check instance health before routing traffic.

## Blue/Green Deployment Flow

```text
S3
 │
 │ app-green.zip
 ▼
CodeDeploy
 │
 ▼
Replacement ASG
 │
 ▼
GREEN EC2 Instances
 │
 ▼
Health Checks
 │
 ▼
Traffic Shift
 │
 ▼
GREEN Production
```

CodeDeploy creates a replacement Auto Scaling group based on the existing `blue-asg`, registers the new instances with `blue-tg`, and shifts traffic after the replacement fleet is ready.

## Rollback

The original BLUE instances remain available during the configured termination wait period, providing an opportunity to stop and roll back the deployment when the rollback option is available.

## Region

This project uses the **Mumbai (`ap-south-1`) AWS Region**. Resource names and Availability Zones may need to be adjusted when deploying in another Region.
