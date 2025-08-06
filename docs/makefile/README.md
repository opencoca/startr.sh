# Standardized Makefile Documentation

> A comprehensive, dynamic Makefile that follows industry best practices.

## Overview

The Startr.sh standardized Makefile provides a consistent interface for common development tasks across all projects. It automatically detects project details from Git and provides intelligent defaults.

## Quick Reference

```bash
make help           # Show all available commands
make it_run         # Build and run using startr.sh
make it_build       # Build only using startr.sh  
make deploy         # Deploy to CapRover
make show_vars      # Display all dynamic variables
make setup          # Setup local development environment
```

## Key Features

### 🔄 Dynamic Variables
All variables are automatically extracted from your Git repository:

```makefile
PROJECT := web-dev-startr-sh     # From directory name
OWNER := Startr                 # From git remote URL
BRANCH := develop               # From current git branch
TAG := v1.0.0                   # From git tags
CONTAINER := web-dev-startr-sh-develop  # Combined name
```

### 🚀 Startr.sh Integration
The Makefile seamlessly integrates with startr.sh:

```bash
make it_run         # Equivalent to: bash <(curl -sL startr.sh) run
make it_build       # Equivalent to: bash <(curl -sL startr.sh) build
```

### 📦 CapRover Deployment
Intelligent deployment with submodule support:

```bash
make deploy         # Automatically handles submodules if present
```

### 🔄 Git Flow Support
Complete Git Flow workflow automation:

```bash
make minor_release  # Start minor version release
make patch_release  # Start patch version release
make major_release  # Start major version release
make hotfix         # Start hotfix
make release_finish # Finish current release
make hotfix_finish  # Finish current hotfix
```

## Installation

### Option 1: Download Directly
```bash
curl -sL startr.sh/resources/makefile > Makefile
```

### Option 2: Use Startr.sh
```bash
bash <(curl -sL startr.sh) --get-makefile
```

### Option 3: Copy from Repository
Copy the [standardized Makefile](../../Makefile) to your project root.

## Configuration

### Environment Variables
Create a `.env` file for custom configuration:

```bash
# .env file example
SERVER__HOST=your-server.com
SERVER__USER=deploy
GITHUB_CLIENT_ID=your_github_id
GITHUB_CLIENT_SECRET=your_github_secret
NODE_ENV=production
```

### Prerequisites
- **Git repository** with remote origin
- **Docker** (for container builds)
- **CapRover CLI** (for deployment)
- **Git Flow** (for release management)

## Command Reference

### Build & Run Commands
- `make it_run` - Build and run project using startr.sh
- `make it_build` - Build project only using startr.sh
- `make it_build_n_run` - Build then run (equivalent to it_run)

### Information Commands  
- `make help` - Show all available commands with descriptions
- `make show_vars` - Display all dynamic variables and their values

### Development Commands
- `make setup` - Initialize local development environment
- `make things_clean` - Clean build artifacts (preserves .env)

### Deployment Commands
- `make deploy` - Deploy to CapRover (with submodule support)

### Git Flow Commands
- `make minor_release` - Start new minor version release (1.0.0 → 1.1.0)
- `make patch_release` - Start new patch version release (1.0.0 → 1.0.1)  
- `make major_release` - Start new major version release (1.0.0 → 2.0.0)
- `make hotfix` - Start new hotfix (1.0.0 → 1.0.0.1)
- `make release_finish` - Complete current release and push
- `make hotfix_finish` - Complete current hotfix and push

## Advanced Usage

### Custom Variables
Override dynamic variables:

```bash
make it_run PROJECT=myapp BRANCH=main
```

### Platform-Specific Builds
The Makefile works with platform-specific Dockerfiles:

```bash
# Will use Dockerfile.linux-amd64 if PLATFORM is set
PLATFORM=linux/amd64 make it_build
```

### Submodule Handling
Automatic detection and handling of Git submodules during deployment:

```bash
# Automatically creates tar archive for submodule projects
make deploy
```

## Troubleshooting

### Common Issues

**"CapRover CLI not installed"**
```bash
npm install -g caprover
```

**"Not logged in to CapRover"**
```bash
caprover login
```

**"Git remote not found"**
```bash
git remote add origin https://github.com/user/repo.git
```

**"Git Flow not initialized"**
```bash
git flow init
```

### Debug Variables
Check what the Makefile detected:

```bash
make show_vars
```

Example output:
```
=== Dynamic Variables ===
PROJECTPATH=/Users/dev/my-project
PROJECT=my-project
OWNER=myusername
PROJECT_NAME=my-project
FULL_BRANCH=feature/new-feature
BRANCH=new-feature
TAG=v1.0.0-5-g1234567
CONTAINER=my-project-new-feature
REMOTE_URL=https://github.com/myusername/my-project.git
```

## Best Practices

### 🎯 Single Responsibility
Each make target does one thing well.

### 🔄 DRY Principle  
Variables are extracted once and reused throughout.

### 🧪 YAGNI Approach
Only includes features that are commonly needed.

### 🔒 SOLID Foundation
Open for extension via custom targets, closed for modification of core functionality.

---

**Next**: [Command Reference](commands.md) | [Variables Guide](variables.md) | [Deployment Guide](deployment.md)
