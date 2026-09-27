### File name: `user-data-explained.md`

````markdown
## User Data Script

This script prepares an Amazon Linux EC2 instance to run the application and participate in the AWS CodeDeploy deployment.

## What the Script Does

### 1. Install Required Packages

```bash
dnf install -y httpd ruby wget
````

Installs:

* `httpd` — Apache web server
* `ruby` — Required by the CodeDeploy agent
* `wget` — Downloads the CodeDeploy installer

### 2. Start Apache

```bash
systemctl enable httpd
systemctl start httpd
```

Enables Apache to start automatically and starts it immediately.

### 3. Create Initial Application Files

```bash
echo "BLUE" > /var/www/html/index.html
echo "OK" > /var/www/html/health.html
```

Creates:

* `index.html` — Displays the initial **BLUE** application version.
* `health.html` — Provides the `OK` response used by the ALB health check.

### 4. Install CodeDeploy Agent

```bash
cd /tmp
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
./install auto
```

Downloads and automatically installs the AWS CodeDeploy agent for the Mumbai (`ap-south-1`) Region.

### 5. Start CodeDeploy Agent

```bash
systemctl enable codedeploy-agent
systemctl start codedeploy-agent
```

Enables the CodeDeploy agent to start automatically and starts it on the instance.

## Execution Summary

```text
Install Packages
      ↓
Start Apache
      ↓
Create BLUE Application
      ↓
Create Health Check
      ↓
Install CodeDeploy Agent
      ↓
Start CodeDeploy Agent
      ↓
Instance Ready for Deployment
```

The resulting EC2 instance is ready to serve the initial BLUE version and receive deployments managed by AWS CodeDeploy.

````
