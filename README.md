## AWS Blue/Green Deployment with CodeDeploy 🔄

This project demonstrates a Blue/Green deployment workflow on AWS using **AWS CodeDeploy, EC2, Auto Scaling, and an Application Load Balancer**.

The deployment starts with a BLUE environment serving traffic. CodeDeploy creates a replacement environment, deploys the GREEN revision, validates the new instances through health checks, and shifts traffic to GREEN.

The repository includes the deployment packages, IAM policy, user-data script, architecture documentation, execution workflow, deployment guide, cleanup guide, and deployment demo.

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

## 📁 Repository Structure

```text
aws-blue-green-deployment-codedeploy/
│
├── applications/
│   ├── README.md
│   ├── app-blue.zip
│   └── app-green.zip
│
├── iam/
│   ├── CodeDeployBlueGreenASG.json
│   └── CodeDeployBlueGreenASG-explained.md
│
├── scripts/
│   ├── user-data.sh
│   └── user-data-explained.md
│
├── README.md
├── architecture-overview.md
├── cleanup-guide.md
├── demo.md
├── deployment-demo.md
├── deployment-guide.md
└── execution-workflow.md
````
## 📄 File Description

| File                                      | Description                                                                                                            |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `README.md`                               | Provides an overview of the project, AWS services used, repository structure, and deployment flow.                     |
| `architecture-overview.md`                | Describes the AWS architecture and the components involved in the Blue/Green deployment.                               |
| `deployment-guide.md`                     | Provides the step-by-step instructions for setting up the AWS infrastructure and performing the Blue/Green deployment. |
| `execution-workflow.md`                   | Explains the deployment workflow from the BLUE environment through the GREEN traffic shift.                            |
| `cleanup-guide.md`                        | Provides the steps for removing the AWS resources created for the project.                                             |
| `demo.md`                                 | Provides additional project/demo information and deployment verification details.                                      |
| `deployment-demo.md`                      | Shows the visual transition from the BLUE environment to the GREEN environment using deployment screenshots.           |
| `applications/README.md`                  | Explains the application deployment packages and the purpose of the BLUE and GREEN revisions.                          |
| `applications/app-blue.zip`               | Contains the BLUE application revision used as the initial deployment version.                                         |
| `applications/app-green.zip`              | Contains the GREEN application revision used for the Blue/Green deployment.                                            |
| `iam/CodeDeployBlueGreenASG.json`         | Contains the inline IAM policy required for CodeDeploy to launch and tag EC2 instances and pass the required IAM role. |
| `iam/CodeDeployBlueGreenASG-explained.md` | Provides a short explanation of the permissions defined in the CodeDeploy Blue/Green IAM policy.                       |
| `scripts/user-data.sh`                    | EC2 user-data script that installs Apache and the CodeDeploy agent and prepares the instance for deployment.           |
| `scripts/user-data-explained.md`          | Explains what each section of the EC2 user-data script does.                                                           |


## 🏗️ AWS Services Used

* **AWS CodeDeploy** — Blue/Green deployment orchestration
* **Amazon EC2** — Application instances
* **Amazon EC2 Auto Scaling** — Manages the BLUE and replacement instance fleets
* **Application Load Balancer** — Routes application traffic
* **Amazon S3** — Stores deployment artifacts
* **Amazon VPC** — Provides the networking environment
* **AWS IAM** — Manages deployment and instance permissions

## 🚀 Deployment Flow

```text
BLUE Environment
       ↓
AWS CodeDeploy
       ↓
Replacement ASG
       ↓
GREEN EC2 Instances
       ↓
Health Checks
       ↓
Traffic Shift
       ↓
GREEN Environment
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

## 🔵🟢 Blue/Green Deployment

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

## 🤝 Let's Connect

- 💼 **LinkedIn:** https://www.linkedin.com/in/khushi-nandwani/
- 💻 **GitHub:** https://github.com/Knandwani07
- ✍️ **Dev Community:** https://dev.to/khushi_nandwani07
- 📝 **Medium:** https://medium.com/@khushinandwanii
- 🌐 **Portfolio:** https://main.d1n4wt6uo5bfx6.amplifyapp.com/

---

⭐ **If you found this project helpful, consider giving it a star!**

