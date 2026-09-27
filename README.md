## AWS Blue/Green Deployment with CodeDeploy

A hands-on AWS project demonstrating **Blue/Green deployment** using AWS CodeDeploy, EC2 Auto Scaling, Application Load Balancer, and Amazon S3.

The project deploys a new application version to a replacement fleet, validates the instances through health checks, shifts traffic from the existing environment to the new version, and provides a rollback window.

## 📌 Project Overview

This project demonstrates how to:

* Set up an AWS environment for Blue/Green deployment
* Store deployment artifacts in Amazon S3
* Configure EC2 instances with the CodeDeploy agent
* Use an Application Load Balancer for traffic routing
* Create an Auto Scaling group for the production environment
* Configure an AWS CodeDeploy Blue/Green deployment group
* Deploy a GREEN application version
* Shift traffic from BLUE to GREEN
* Roll back to the previous version when required
* Clean up the AWS resources after testing

## 🏗️ AWS Services Used

* **AWS CodeDeploy**
* **Amazon EC2**
* **EC2 Auto Scaling**
* **Application Load Balancer (ALB)**
* **Amazon S3**
* **Amazon VPC**
* **AWS IAM**
* **Security Groups**

## 📂 Project Structure

```text
aws-blue-green-deployment-codedeploy/
│
├── app-blue/
│   ├── appspec.yml
│   ├── index.html
│   └── health.html
│
├── app-green/
│   ├── appspec.yml
│   ├── index.html
│   └── health.html
│
├── policies/
│   └── CodeDeployBlueGreenASG.json
│
├── scripts/
│   └── user-data.sh
│
├── diagrams/
│   └── architecture.png
│
└── README.md
```

## ⚙️ Architecture

The deployment architecture uses an Application Load Balancer in front of EC2 instances managed by Auto Scaling.

The initial **BLUE** environment serves the application. During deployment, CodeDeploy creates a replacement Auto Scaling fleet, installs the GREEN revision, validates the instances through the target group's health checks, and reroutes traffic to the replacement fleet.

## 🚀 Deployment Flow

```text
Amazon S3
   │
   │  app-green.zip
   ▼
AWS CodeDeploy
   │
   ▼
Replacement Auto Scaling Group
   │
   ▼
EC2 Instances
   │
   ▼
Health Checks
   │
   ▼
Application Load Balancer
   │
   ▼
GREEN Application
```

## 📦 Deployment Packages

Two application packages are used:

* `app-blue.zip` — BLUE application version
* `app-green.zip` — GREEN application version

Each package contains:

```text
appspec.yml
index.html
health.html
```

`appspec.yml` must be located at the root of each ZIP package.

## 🔄 Blue/Green Deployment

The deployment process follows these general stages:

1. BLUE version is running in production.
2. GREEN revision is uploaded to Amazon S3.
3. CodeDeploy starts a Blue/Green deployment.
4. CodeDeploy creates a replacement Auto Scaling group.
5. GREEN instances are launched.
6. Instances register with the target group.
7. Health checks validate the replacement instances.
8. Traffic is rerouted from BLUE to GREEN.
9. Original instances remain available during the termination wait period.
10. Original instances are terminated after the configured wait period.

## ↩️ Rollback

During the termination wait period, the previous BLUE environment can remain available as a fallback.

The deployment can also be stopped and rolled back when the rollback option is available.

Redeploying `app-blue.zip` is different from a rollback because it starts a new Blue/Green deployment cycle.

## 🧹 Cleanup

After completing the deployment test, remove the AWS resources created for the project to avoid unnecessary charges.

Resources include:

* CodeDeploy application and deployment group
* Auto Scaling groups
* EC2 instances
* Launch template
* Application Load Balancer
* Target group
* Security groups
* S3 bucket and objects
* IAM roles
* VPC and associated resources

## ⚠️ Notes

* This project uses the **Mumbai (`ap-south-1`) AWS Region**.
* Resource names and Availability Zones may need to be changed when using another AWS Region.
* AWS resources such as EC2 instances and Application Load Balancers may incur charges.
* The IAM permissions used in this demonstration should be reviewed and scoped appropriately before using a similar architecture in production.

## 📚 Documentation

Detailed setup instructions, AWS console configuration, deployment steps, rollback workflow, and cleanup instructions will be added here.

## 👤 Author

**Khushi Nandwani**

* GitHub: https://github.com/Knandwani07
* LinkedIn: https://www.linkedin.com/in/khushi-nandwani/

## 📄 License

This project is intended for learning and demonstration purposes.
