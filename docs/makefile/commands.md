# Makefile Commands Reference

> Complete reference for all standardized Makefile commands.

## Command Categories

### 🚀 Build & Run Commands

#### `make it_run`
**Purpose**: Build and run your project using startr.sh
**Equivalent**: `bash <(curl -sL startr.sh) run`

```bash
make it_run
```

**What it does**:
1. Downloads and executes startr.sh
2. Detects project type automatically
3. Builds Docker image if needed
4. Runs container with appropriate port mappings

**Port mappings**:
- `8888:8888` - Jupyter notebooks
- `8000:8000` - Development servers
- `8080:8080` - Web applications  
- `9000:5000` - Flask/Python apps

---

#### `make it_build`
**Purpose**: Build Docker image only (no run)
**Equivalent**: `bash <(curl -sL startr.sh) build`

```bash
make it_build
```

**What it does**:
1. Downloads and executes startr.sh in build mode
2. Creates Docker image with dynamic tags
3. Does not start container

**Generated tags**:
- `startr/PROJECT-BRANCH:TAG`
- `startr/PROJECT-BRANCH:latest`

---

#### `make it_build_n_run`
**Purpose**: Build then run (same as `it_run`)
**Equivalent**: `bash <(curl -sL startr.sh) build && bash <(curl -sL startr.sh) run`

```bash
make it_build_n_run
```

---

### 📊 Information Commands

#### `make help`
**Purpose**: Display all available commands with descriptions

```bash
make help
```

**Output example**:
```
================================================
       Startr/WEB-DEV-startr.sh by Startr.Cloud
================================================
This is the default make command.
This command lists available make commands.

Usage example:
    make it_run

Available make commands:

custom_release
deploy
help
hotfix
hotfix_finish
it_build
it_build_n_run
it_run
major_release
minor_release
patch_release
release
release_finish
setup
show_vars
things_clean
update_submodules
```

---

#### `make show_vars`
**Purpose**: Display all dynamic variables and their current values

```bash
make show_vars
```

**Output example**:
```
=== Dynamic Variables ===
PROJECTPATH=/Users/dev/WEB-Startr.sh
PROJECT=web-startr-sh
OWNER=Startr
PROJECT_NAME=WEB-Startr.sh
FULL_BRANCH=feature/docs-enhancement
BRANCH=docs-enhancement
TAG=v0.1.1-12-g8a3b2c1
CONTAINER=web-startr-sh-docs-enhancement
REMOTE_URL=https://github.com/Startr/WEB-DEV-startr.sh.git
```

---

### 🛠️ Development Commands

#### `make setup`
**Purpose**: Initialize local development environment

```bash
make setup
```

**What it does**:
1. Creates `.env` file with default values if it doesn't exist
2. Sets up basic environment variables
3. Prepares development environment

**Created `.env` file**:
```bash
SERVER__HOST=localhost
SERVER__USER=root
SERVER__CONTAINER_FILTER=
GITHUB_CLIENT_ID=Ov23lic87oTTC3OljekI
GITHUB_CLIENT_SECRET=your_github_client_secret_here
NODE_ENV=development
```

---

#### `make things_clean`
**Purpose**: Clean build artifacts while preserving .env

```bash
make things_clean
```

**What it does**:
- Runs `git clean --exclude=!.env -Xdf`
- Removes all gitignored files except .env
- Useful for fresh builds

---

#### `make update_submodules`
**Purpose**: Provide instructions for updating Git submodules

```bash
make update_submodules
```

**Output**:
```
Developer instructions: Please update your Dockerfile manually to add the 
appropriate 'RUN' command for installing git (using apt-get or apk) and to 
include the submodule update command. Then run 'git submodule update --init --recursive'.
```

---

### 🚀 Deployment Commands

#### `make deploy`
**Purpose**: Deploy to CapRover with intelligent submodule handling

```bash
make deploy
```

**Prerequisites**:
- CapRover CLI installed: `npm install -g caprover`
- Logged in to CapRover: `caprover login`

**What it does**:
1. Checks for CapRover CLI installation
2. Verifies CapRover login status
3. Detects Git submodules automatically
4. If submodules exist:
   - Creates tar archive with all files
   - Deploys using tar file
   - Cleans up tar file
5. If no submodules:
   - Deploys normally using git

**Submodule handling**:
```bash
# Creates archive including submodules
git ls-files --recurse-submodules | tar -czf deploy.tar -T -
npx caprover deploy -t ./deploy.tar
rm ./deploy.tar
```

---

### 🔄 Git Flow Commands

See the [Git Flow release guide](git-flow.md) for setup, release steps, and recovery.

#### `make minor_release`
**Purpose**: Start a minor release branch.

**What it does**: Uses the newest tag matching `v[0-9]*` and increments the minor version.

#### `make patch_release`
**Purpose**: Start a patch release branch.

**What it does**: Uses the newest tag matching `v[0-9]*` and increments the patch version.

#### `make major_release`
**Purpose**: Start a major release branch.

**What it does**: Uses the newest tag matching `v[0-9]*` and increments the major version.

#### `make hotfix`
**Purpose**: Start a hotfix branch from `master`.

**What it does**: Uses the newest tag matching `v[0-9]*` and increments the fourth version number.

#### `make custom_release`
**Purpose**: Start a release at a chosen version.

**What it does**: Requires a valid `VER` value, such as `2.1.0`, and starts a release branch at that version.

#### `make release_finish`
**Purpose**: Finish the current release or hotfix.

**What it does**: Runs tests when the repository has a `test` target, merges into `master`, tags the release, merges the tag into `develop`, deletes the branch, and pushes `develop`, `master`, and the tag.

#### `make hotfix_finish`
**Purpose**: Finish the current hotfix.

**What it does**: Runs the same finish flow as `make release_finish`.

#### `make release`
**Purpose**: Run the whole release interactively.

**What it does**: Uses `git-release` to ask for the type, start the release, pause for review, finish it, and offer `it_build_multi_arch_push_GHCR` and `it_deploy` when available.

---

## Dynamic Variables Explained

### Variable Extraction Process

The Makefile automatically extracts these variables from your Git repository:

```makefile
# Get project root path
PROJECTPATH := $(shell git rev-parse --show-toplevel)

# Extract project name from directory
PROJECT := $(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]')

# Get current branch
FULL_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BRANCH := $(shell echo $(FULL_BRANCH) | sed 's/.*\///' | tr '[:upper:]' '[:lower:]')

# Get git tag
TAG := $(shell git describe --always --tag)

# Extract owner and project from remote URL
REMOTE_URL := $(shell git config --get remote.origin.url 2>/dev/null || echo "unknown/unknown")
OWNER := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$$|\1|')
PROJECT_NAME := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/][^/]+/([^/]+)(.git)?$$|\1|' | sed 's/\.git$$//')

# Create container name
CONTAINER := $(PROJECT)-$(BRANCH)
```

### Variable Usage Examples

These variables are used throughout the Makefile:

```makefile
# In help command
@echo "       $(OWNER)/$(PROJECT_NAME) by Startr.Cloud"

# In Docker commands (via startr.sh)
# Container name: startr/PROJECT-BRANCH:TAG
# Example: startr/web-startr-sh-main:v1.0.0
```

## Customization

### Override Variables
```bash
# Override project name
make it_run PROJECT=myapp

# Override branch for testing
make it_build BRANCH=main

# Override multiple variables
make deploy PROJECT=myapp OWNER=mycompany
```

### Custom Targets
Add your own targets to extend functionality:

```makefile
# Add to your project's Makefile
test:
	npm test

lint:
	npm run lint

custom_deploy:
	@echo "Custom deployment for $(PROJECT)"
	# Your custom commands here
```

### Environment File
The Makefile loads variables from `.env`:

```bash
# .env
SERVER__HOST=production.example.com
SERVER__USER=deploy
CUSTOM_VAR=value
```

## Troubleshooting

### Common Issues

**"No rule to make target"**
```bash
# Check if you're in the right directory
pwd
ls -la Makefile

# Verify Makefile syntax
make -n help
```

**"git command not found"**
```bash
# Install Git
# macOS:
brew install git

# Ubuntu/Debian:
sudo apt-get install git
```

**"CapRover not found"**
```bash
# Install CapRover CLI
npm install -g caprover

# Verify installation
caprover --version
```

**"Git Flow not initialized"**
```bash
git flow init -d -m master -e develop -t v
```

**"Remote URL not found"**
```bash
# Add remote origin
git remote add origin https://github.com/user/repo.git

# Verify
git remote -v
```

### Debug Commands

```bash
# Check what variables are detected
make show_vars

# Test make command without execution
make -n it_run

# Show all make rules
make help

# Verbose output
make -d it_build
```

---

**See also**: [Variables Guide](variables.md) | [Deployment Guide](deployment.md) | [Main Documentation](README.md)
