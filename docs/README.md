# Startr.sh Documentation

> Clean, clear, and concise documentation for the ultimate project launchpad.

## Quick Start

```bash
# Build and run your project
bash <(curl -sL startr.sh)

# Or use the standardized Makefile
make it_run
```

## What is Startr.sh?

Startr.sh is both **a landing page** and **the actual script** - when you visit [startr.sh](https://startr.sh), you're seeing an HTML page that contains the complete bash script at the bottom. This innovative approach means:

- ✅ **One URL** serves both documentation and the script
- ✅ **Always in sync** - the docs and script can't get out of date
- ✅ **Transparent** - you can see exactly what code you're running

## Core Components

### 🛠️ [Standardized Makefile](makefile/)
Pre-configured Make commands for common development tasks.

### 🚀 [Startr.sh Script](../src/index.njk)
The smart build and run script that detects your project type.

### 📖 [Development Workflow](development/)
Following industry best practices with Plan-Document-Execute-Verify.

## Documentation Structure

```
docs/
├── README.md              # This file - main documentation index
├── makefile/              # Makefile documentation
│   ├── README.md          # Makefile overview and setup
│   ├── commands.md        # Complete command reference
│   ├── variables.md       # Dynamic variables explanation
│   └── deployment.md      # CapRover deployment guide
├── development/           # Development workflow documentation
│   └── DEVELOPMENT_WORKFLOW.md
└── examples/              # Usage examples and templates
    └── (coming soon)
```

## Key Features

### Smart Project Detection
Startr.sh automatically detects your project type:
- **Node.js** (with npm or bun)
- **Python** (with pipenv)
- **Static sites**
- **And more**

### Dynamic Configuration
Both the Makefile and startr.sh script use dynamic variables:
- Project name from directory
- Git branch for container naming
- Git tags for versioning
- Owner extraction from git remote

### One-Command Setup
```bash
# Complete project setup
bash <(curl -sL startr.sh)

# Or specific actions
bash <(curl -sL startr.sh) build
bash <(curl -sL startr.sh) run
```

## Getting Help

- **Issues**: Report bugs on [GitHub Issues](https://github.com/Startr/WEB-DEV-startr.sh/issues)
- **Questions**: Ask in [GitHub Discussions](https://github.com/Startr/WEB-DEV-startr.sh/discussions)
- **Contributing**: See [DEVELOPMENT_WORKFLOW.md](development/DEVELOPMENT_WORKFLOW.md)

---

*Built with ❤️ by [Startr.Cloud](https://startr.cloud) following SOLID principles and industry best practices.*
