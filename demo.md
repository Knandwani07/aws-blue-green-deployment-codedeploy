## Deployment Demo

This section shows the Blue/Green deployment in action through the Application Load Balancer endpoint.

### BLUE Environment

The initial deployment serves the BLUE application through the ALB.

<img width="1527" height="775" alt="Screenshot 2026-09-20 205210" src="https://github.com/user-attachments/assets/a3f7f03d-4d48-44bb-b610-adf3ea8e54a6" />


The page displays **BLUE ENVIRONMENT**, confirming that the current production environment is serving traffic.

### GREEN Environment

After the CodeDeploy Blue/Green deployment completes and traffic is shifted, the same ALB endpoint serves the GREEN application.

<img width="1456" height="727" alt="image" src="https://github.com/user-attachments/assets/905ee6c3-4509-4c84-ad8e-452a82bae3ea" />


The page displays **GREEN**, confirming that traffic has been shifted to the new application version.

### What This Demonstrates

```text
BLUE Environment
       │
       │ CodeDeploy Deployment
       ▼
Replacement GREEN Environment
       │
       │ Health Check
       ▼
Traffic Shift
       │
       ▼
GREEN Environment
