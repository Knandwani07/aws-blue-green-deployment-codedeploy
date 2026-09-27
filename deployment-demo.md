## Blue/Green Deployment Demo

This section provides a visual demonstration of the Blue/Green deployment process using the Application Load Balancer endpoint.

### BLUE Environment

The initial application is deployed to the BLUE environment and serves production traffic.

<img width="1456" height="735" alt="image" src="https://github.com/user-attachments/assets/f6fd8926-ce18-4bc8-bb5e-295d466fa48d" />


The page displays **BLUE ENVIRONMENT**, confirming that the original environment is serving traffic.

### GREEN Environment

After CodeDeploy creates the replacement environment, validates the instances, and shifts traffic, the same ALB endpoint serves the GREEN application.


<img width="1456" height="735" alt="image" src="https://github.com/user-attachments/assets/a6ba30b8-17f8-4e5b-b5ea-8d42d47a1929" />


The page displays **GREEN**, confirming that traffic has been shifted to the new environment.

### Deployment Flow

```text
BLUE
  ↓
CodeDeploy Deployment
  ↓
Replacement EC2 Instances
  ↓
Health Checks
  ↓
Traffic Shift
  ↓
GREEN
