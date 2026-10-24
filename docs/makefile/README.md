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
git-flow-next starts a release or hotfix branch; plain git finishes it. The finish runs `make test` first when the repo has a test target, and re-running it is safe. Full guide: [git-flow.md](git-flow.md).

```bash
make minor_release  # Start minor version release
make patch_release  # Start patch version release
make major_release  # Start major version release
make hotfix         # Start hotfix (fourth number)
make custom_release VER=2.1.0  # Start a chosen version
make release_finish # Finish the release or hotfix and push
make release        # The whole release, run by git-release
```

## Installation

### Option 1: Download Directly
```bash
curl -fsSL https://startr.sh/Makefile -o Makefile
```

Container projects also add the block from `https://startr.sh/Makefile.docker` after the standard variables.

### Option 2: Use CEP
```bash
bash <(curl -fsSL startr.sh/cep)
```

CEP offers the Makefile when the project has none. It never touches an existing Makefile.

### Option 3: Update an Existing Makefile
Replace everything between the two `startr release block v2` marker lines with the block from `https://startr.sh/Makefile`. See [git-flow.md](git-flow.md).

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
- **A container runtime** (for container builds): on a Mac, Colima set up by `sage-runtime`; Docker Desktop and OrbStack still work
- **CapRover CLI** (for deployment)
- **git-flow-next** and **git-release** (for releases)

When a tool is missing, the Makefile offers to install it through `startr.sh/scripts/tools.sh`. It asks before every install.

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
- `make custom_release VER=2.1.0` - Start a release at a chosen version
- `make release_finish` - Test, merge, tag and push the current release or hotfix
- `make hotfix_finish` - The same as `make release_finish`
- `make release` - Run the whole release with git-release

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
