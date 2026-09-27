## Application Deployment Packages

This folder contains the two application revisions used by AWS CodeDeploy for the Blue/Green deployment.

### `app-blue`

The BLUE revision represents the current production version.

Its `index.html` displays:

```text
BLUE ENVIRONMENT
Currently serving traffic
````

### `app-green`

The GREEN revision represents the new application version being deployed.

Its `index.html` displays:

```text
GREEN
Currently serving traffic
```

The different pages make it easy to visually verify when CodeDeploy has shifted production traffic from BLUE to GREEN.

## Deployment Files

### `appspec.yml`

Defines how CodeDeploy installs and manages the application files and specifies the lifecycle hooks executed during deployment.

### `index.html`

Provides the visible application page used to identify the active deployment version.

* `app-blue` → BLUE
* `app-green` → GREEN

### `health.html`

Returns `OK` and is used by the Application Load Balancer health check to verify that the web server is serving content correctly.

### `scripts/before_install.sh`

Runs before the new revision is installed. It ensures Apache is installed and removes the previous application files.

### `scripts/after_install.sh`

Runs after the application files are copied. It sets the required ownership and permissions for the Apache web server.

### `scripts/start_server.sh`

Enables and restarts Apache so the newly deployed application is served.

### `scripts/validate_service.sh`

Checks whether the local web server successfully returns HTTP `200` from `/health.html`. It retries the check before reporting a failure.

## Deployment Lifecycle

The CodeDeploy hooks execute in this order:

```text
BeforeInstall
      ↓
Copy Application Files
      ↓
AfterInstall
      ↓
ApplicationStart
      ↓
ValidateService
```

Together, these files provide the application content and the deployment lifecycle actions required for CodeDeploy to install, start, and validate each revision.
