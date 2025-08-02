help: 
	@echo "================================================"
	@echo "       $(OWNER)/$(PROJECT_NAME) by Startr.Cloud"
	@echo "================================================"
	@echo "This is the default make command."
	@echo "This command lists available make commands."
	@echo ""
	@echo "Usage example:"
	@echo "    make it_run"
	@echo ""
	@echo "Available make commands:"
	@echo ""
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ { \
		if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | \
		grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo ""

# Dynamic variable extraction (same as startr.sh)
PROJECTPATH := $(shell git rev-parse --show-toplevel)
PROJECT := $(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]')
FULL_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BRANCH := $(shell echo $(FULL_BRANCH) | sed 's/.*\///' | tr '[:upper:]' '[:lower:]')
TAG := $(shell git describe --always --tag)

# Extract owner and project from git remote URL
REMOTE_URL := $(shell git config --get remote.origin.url 2>/dev/null || echo "unknown/unknown")
OWNER := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$$|\1|')
PROJECT_NAME := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/][^/]+/([^/]+)(.git)?$$|\1|' | sed 's/\.git$$//')

# Docker container name (dynamic based on project and branch)
CONTAINER := $(PROJECT)-$(BRANCH)

# Load environment variables from .env file if it exists
-include .env

# Default values for environment variables (if not set in .env)
#SERVER__HOST ?= SERVER_
#SERVER__USER ?= root
#SERVER__CONTAINER_FILTER ?= 

it_run:
	@bash -c 'bash <(curl -sL startr.sh) run'

it_build:
	@bash -c 'bash <(curl -sL startr.sh) build'

it_build_n_run:
	@bash -c 'bash <(curl -sL startr.sh) build && bash <(curl -sL startr.sh) run'

show_vars:
	@echo "=== Dynamic Variables ==="
	@echo "PROJECTPATH=$(PROJECTPATH)"
	@echo "PROJECT=$(PROJECT)"
	@echo "OWNER=$(OWNER)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "FULL_BRANCH=$(FULL_BRANCH)"
	@echo "BRANCH=$(BRANCH)"
	@echo "TAG=$(TAG)"
	@echo "CONTAINER=$(CONTAINER)"
	@echo "REMOTE_URL=$(REMOTE_URL)"
	@echo ""


update_submodules:
	@echo "Developer instructions: Please update your Dockerfile manually to add the appropriate 'RUN' command for installing git (using apt-get or apk) and to include the submodule update command. Then run 'git submodule update --init --recursive'."

# Check if .gitmodules exists (returns 1 if present, empty otherwise)
HAS_SUBMODULE := $(shell [ -f .gitmodules ] && echo 1)

# for deployment to work we need to be logged in to caprover
# and have the caprover CLI installed
# check if caprover is installed
HAS_CAPROVER := $(shell which caprover 2>/dev/null && echo 1)
# check if we are logged in to caprover
HAS_CAPROVER_LOGIN := $(shell caprover ls | grep -q "Logged in" && echo 1)

deploy:
	@if [ "$(HAS_CAPROVER)" = "" ]; then \
		echo "CapRover CLI is not installed. Please install it first."; \
		echo "You can install it using npm: npm install -g caprover"; \
		exit 1; \
	elif [ "$(HAS_CAPROVER_LOGIN)" = "" ]; then \
		echo "You are not logged in to CapRover."; \
		echo "Please log in using the command: caprover login"; \
		exit 1; \
	fi
	@if [ "$(HAS_SUBMODULE)" = "1" ]; then \
		echo "Submodules detected."; \
		echo "We will create a tar of the project and deploy it"; \
		echo "Creating tar of project..."; \
		echo -e "\a"; \
		git ls-files --recurse-submodules | tar -czf deploy.tar -T -; \
		echo "Deploying to CapRover using the tar file..."; \
		npx caprover deploy -t ./deploy.tar; \
		rm ./deploy.tar; \
	else \
		echo "No submodules detected. Deploying normally..."; \
		npx caprover deploy; \
	fi

minor_release:
	# Start a minor release with incremented minor version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2+1".0"}') && echo "or use 'make release_finish' to finish the release"

patch_release:
	# Start a patch release with incremented patch version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}') && echo "or use 'make release_finish' to finish the release"

major_release:
	# Start a major release with incremented major version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1+1".0.0"}') && echo "or use 'make release_finish' to finish the release"

hotfix:
	# Start a hotfix with incremented n.n.n.n version (incrementing the fourth number)
	git flow hotfix start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3"."$$4+1}') && echo "or use 'make hotfix_finish' to finish the hotfix"

release_finish:
	git flow release finish "$$(git branch --show-current | sed 's/release\///')" && git push origin develop && git push origin master && git push --tags && git checkout develop

hotfix_finish:
	git flow hotfix finish "$$(git branch --show-current | sed 's/hotfix\///')" && git push origin develop && git push origin master && git push --tags && git checkout master

things_clean:
	git clean --exclude=!.env -Xdf

setup:
	@echo "Setting up local development environment..."
	@if [ ! -f .env ]; then \
		echo "Creating .env file with default values..."; \
		echo "SERVER__HOST=localhost" > .env; \
		echo "SERVER__USER=root" >> .env; \
		echo "SERVER__CONTAINER_FILTER=" >> .env; \
		echo "GITHUB_CLIENT_ID=Ov23lic87oTTC3OljekI" >> .env; \
		echo "GITHUB_CLIENT_SECRET=your_github_client_secret_here" >> .env; \
		echo "NODE_ENV=development" >> .env; \
		echo "You can customize the .env file later."; \
	fi
	@echo "Setup complete! Local development environment is ready."

cep_fix_links:
	@echo "Fixing CEP hard links after git operations..."
	@if [ ! -d src/cep ]; then \
		echo "Creating CEP directory..."; \
		mkdir -p src/cep; \
	fi
	@echo "Recreating hard links for CEP files..."
	@if [ -f src/cep/CONVENTION.instructions.md ]; then \
		rm src/cep/CONVENTION.instructions.md; \
	fi
	@if [ -f src/cep/DEVELOPMENT_WORKFLOW.md ]; then \
		rm src/cep/DEVELOPMENT_WORKFLOW.md; \
	fi
	@ln CONVENTION.instructions.md src/cep/CONVENTION.instructions.md
	@ln docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md
	@echo "CEP hard links recreated successfully!"
	@echo "Verifying links..."
	@ls -li CONVENTION.instructions.md src/cep/CONVENTION.instructions.md | awk '{print "CONVENTION inode: " $$1}'
	@ls -li docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md | awk '{print "WORKFLOW inode: " $$1}'

cep_status:
	@echo "=== CEP Hard Links Status ==="
	@if [ -f src/cep/CONVENTION.instructions.md ]; then \
		echo "CONVENTION.instructions.md:"; \
		ls -li CONVENTION.instructions.md src/cep/CONVENTION.instructions.md; \
		if [ "$$(stat -f '%i' CONVENTION.instructions.md 2>/dev/null)" = "$$(stat -f '%i' src/cep/CONVENTION.instructions.md 2>/dev/null)" ]; then \
			echo "✅ Hard link is working"; \
		else \
			echo "❌ Hard link is broken"; \
		fi; \
	else \
		echo "❌ CEP CONVENTION.instructions.md not found"; \
	fi
	@echo ""
	@if [ -f src/cep/DEVELOPMENT_WORKFLOW.md ]; then \
		echo "DEVELOPMENT_WORKFLOW.md:"; \
		ls -li docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md; \
		if [ "$$(stat -f '%i' docs/DEVELOPMENT_WORKFLOW.md 2>/dev/null)" = "$$(stat -f '%i' src/cep/DEVELOPMENT_WORKFLOW.md 2>/dev/null)" ]; then \
			echo "✅ Hard link is working"; \
		else \
			echo "❌ Hard link is broken"; \
		fi; \
	else \
		echo "❌ CEP DEVELOPMENT_WORKFLOW.md not found"; \
	fi

docs_fix_links:
	@echo "Creating documentation symlinks for website..."
	@mkdir -p src/docs
	@cd src/docs && ln -sf ../../docs/makefile/README.md makefile-guide.md
	@cd src/docs && ln -sf ../../docs/makefile/commands.md makefile-commands.md
	@cd src/docs && ln -sf ../../docs/makefile/variables.md makefile-variables.md
	@cd src/docs && ln -sf ../../docs/makefile/deployment.md makefile-deployment.md
	@echo "✅ Documentation symlinks created successfully!"

docs_status:
	@echo "=== Documentation Symlinks Status ==="
	@for doc in makefile-guide makefile-commands makefile-variables makefile-deployment; do \
		if [ -L "src/docs/$$doc.md" ]; then \
			echo "$$doc.md:"; \
			ls -la "src/docs/$$doc.md"; \
			if [ -f "src/docs/$$doc.md" ]; then \
				echo "✅ Symlink is working"; \
			else \
				echo "❌ Symlink is broken"; \
			fi; \
		else \
			echo "❌ $$doc.md symlink not found"; \
		fi; \
		echo ""; \
	done

install_hooks:
	@echo "Installing git hooks..."
	@if [ ! -d scripts/hooks ]; then \
		echo "❌ scripts/hooks directory not found"; \
		exit 1; \
	fi
	@for hook in scripts/hooks/*; do \
		if [ -f "$$hook" ]; then \
			hook_name=$$(basename "$$hook"); \
			echo "Installing $$hook_name hook..."; \
			cp "$$hook" ".git/hooks/$$hook_name"; \
			chmod +x ".git/hooks/$$hook_name"; \
			echo "✅ $$hook_name hook installed"; \
		fi; \
	done
	@echo "🎉 All hooks installed successfully!"

uninstall_hooks:
	@echo "Uninstalling project-specific git hooks..."
	@for hook in scripts/hooks/*; do \
		if [ -f "$$hook" ]; then \
			hook_name=$$(basename "$$hook"); \
			if [ -f ".git/hooks/$$hook_name" ]; then \
				echo "Removing $$hook_name hook..."; \
				rm ".git/hooks/$$hook_name"; \
				echo "✅ $$hook_name hook removed"; \
			fi; \
		fi; \
	done
	@echo "🎉 All project hooks uninstalled!"
