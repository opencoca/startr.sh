# Dynamic Variables Guide

> Understanding how the Makefile automatically extracts project information.

## Overview

The standardized Makefile uses dynamic variable extraction to automatically configure itself for any project. No manual configuration required - it reads everything from your Git repository.

## Core Variables

### `PROJECTPATH`
**Source**: `git rev-parse --show-toplevel`
**Purpose**: Absolute path to the project root
**Example**: `/Users/dev/my-awesome-project`

```makefile
PROJECTPATH := $(shell git rev-parse --show-toplevel)
```

### `PROJECT`
**Source**: Directory name (lowercase)
**Purpose**: Container and image naming
**Example**: `my-awesome-project`

```makefile
PROJECT := $(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]')
```

### `OWNER`
**Source**: Git remote URL parsing
**Purpose**: Image namespacing
**Example**: `myusername` (from `https://github.com/myusername/repo.git`)

```makefile
OWNER := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$$|\1|')
```

### `PROJECT_NAME`
**Source**: Git remote URL parsing
**Purpose**: Repository name extraction
**Example**: `my-awesome-project` (from `https://github.com/user/my-awesome-project.git`)

```makefile
PROJECT_NAME := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/][^/]+/([^/]+)(.git)?$$|\1|' | sed 's/\.git$$//')
```

### `BRANCH`
**Source**: Current Git branch (cleaned)
**Purpose**: Environment-specific builds
**Example**: `main`, `develop`, `feature-auth`

```makefile
FULL_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BRANCH := $(shell echo $(FULL_BRANCH) | sed 's/.*\///' | tr '[:upper:]' '[:lower:]')
```

### `TAG`
**Source**: Git describe
**Purpose**: Version identification
**Example**: `v1.0.0`, `v1.0.0-5-g1a2b3c4`

```makefile
TAG := $(shell git describe --always --tag)
```

### `CONTAINER`
**Source**: Combination of PROJECT and BRANCH
**Purpose**: Unique container naming
**Example**: `my-awesome-project-main`

```makefile
CONTAINER := $(PROJECT)-$(BRANCH)
```

## Real-World Examples

### Example 1: Main Branch
```bash
# Repository: https://github.com/company/web-app.git
# Branch: main
# Latest tag: v2.1.0

PROJECTPATH=/Users/dev/web-app
PROJECT=web-app
OWNER=company
PROJECT_NAME=web-app
FULL_BRANCH=main
BRANCH=main
TAG=v2.1.0
CONTAINER=web-app-main
```

### Example 2: Feature Branch
```bash
# Repository: https://github.com/user/api-service.git  
# Branch: feature/user-authentication
# No tags yet

PROJECTPATH=/Users/dev/api-service
PROJECT=api-service
OWNER=user
PROJECT_NAME=api-service
FULL_BRANCH=feature/user-authentication
BRANCH=user-authentication
TAG=a1b2c3d
CONTAINER=api-service-user-authentication
```

### Example 3: SSH Remote
```bash
# Repository: git@github.com:team/mobile-app.git
# Branch: develop
# Latest tag: v0.3.2-beta

PROJECTPATH=/Users/dev/mobile-app
PROJECT=mobile-app
OWNER=team
PROJECT_NAME=mobile-app
FULL_BRANCH=develop
BRANCH=develop
TAG=v0.3.2-beta
CONTAINER=mobile-app-develop
```

## Variable Usage in Commands

### Docker Image Tags
Generated image names follow this pattern:
```bash
startr/PROJECT-BRANCH:TAG
startr/PROJECT-BRANCH:latest

# Example:
startr/web-app-main:v2.1.0
startr/web-app-main:latest
```

### Container Names
Running containers use:
```bash
PROJECT-BRANCH

# Example:
web-app-main
api-service-user-authentication
```

### Help Display
The help command shows:
```bash
================================================
       OWNER/PROJECT_NAME by Startr.Cloud
================================================

# Example:
================================================
       company/web-app by Startr.Cloud
================================================
```

## Environment File Integration

Variables can be overridden via `.env` file:

```bash
# .env
PROJECT_OVERRIDE=custom-name
BRANCH_OVERRIDE=custom-branch
OWNER_OVERRIDE=custom-owner
```

Load in Makefile:
```makefile
-include .env

# Use override if set, otherwise use dynamic value
PROJECT := $(or $(PROJECT_OVERRIDE),$(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]'))
```

## Advanced Use Cases

### Multi-Platform Builds
```bash
# Platform affects container naming
PLATFORM=linux/arm64 make it_build
# Creates: startr/PROJECT-BRANCH:arm64
```

### Custom Branch Naming
```bash
# Override branch for specific builds
make it_build BRANCH=staging
# Uses: PROJECT-staging instead of detected branch
```

### Development vs Production
```bash
# Development (feature branch)
CONTAINER=web-app-feature-auth

# Production (main branch)  
CONTAINER=web-app-main
```

## Troubleshooting Variables

### Debug Variable Values
```bash
make show_vars
```

### Common Issues

**"Unknown/unknown" in OWNER/PROJECT_NAME**
```bash
# No git remote configured
git remote add origin https://github.com/user/repo.git
```

**Empty PROJECT value**
```bash
# Not in a directory/no git repo
cd /path/to/your/project
git init
```

**Wrong BRANCH value**
```bash
# Not on a branch (detached HEAD)
git checkout main
```

**No TAG value**
```bash
# No git tags exist
git tag v0.1.0
```

### Manual Override
```bash
# Override any variable
make it_run PROJECT=myapp OWNER=myorg BRANCH=main
```

## Variable Validation

### Required Variables
These must have values for proper operation:
- `PROJECTPATH` - Must be a valid directory
- `PROJECT` - Must be a valid container name
- `BRANCH` - Must be a valid branch name

### Optional Variables
These can be empty or default:
- `OWNER` - Defaults to "unknown"
- `TAG` - Falls back to commit hash
- `PROJECT_NAME` - Falls back to PROJECT value

### Validation Script
```bash
#!/bin/bash
# validate-vars.sh

required_vars=(PROJECTPATH PROJECT BRANCH)
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required variable $var is empty"
        exit 1
    fi
done

echo "All required variables are set"
```

## Best Practices

### Repository Setup
```bash
# Ensure proper git setup
git init
git remote add origin https://github.com/user/repo.git
git tag v0.1.0  # Initial tag
```

### Naming Conventions
- **Repositories**: Use kebab-case (`my-awesome-project`)
- **Branches**: Use kebab-case (`feature/user-auth`)
- **Tags**: Use semantic versioning (`v1.2.3`)

### Branch Strategy
```bash
# Good branch names (become good container names)
main → project-main
develop → project-develop
feature/auth → project-auth

# Avoid problematic characters
feature/user_auth → project-user_auth  # underscores OK
feature/user@auth → project-user@auth  # @ problematic
```

---

**See also**: [Commands Reference](commands.md) | [Deployment Guide](deployment.md) | [Main Documentation](README.md)
