help: 
	@echo "================================================"
	@echo "       Startr.sh by Startr.Cloud"
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
	@echo "FULL_BRANCH=$(FULL_BRANCH)"
	@echo "BRANCH=$(BRANCH)"
	@echo "TAG=$(TAG)"
	@echo "CONTAINER=$(CONTAINER)"
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
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2+1".0"}')

patch_release:
	# Start a patch release with incremented patch version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}')

major_release:
	# Start a major release with incremented major version
	git flow release start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1+1".0.0"}')

hotfix:
	# Start a hotfix with incremented patch version
	git flow hotfix start $$(git tag --sort=-v:refname | sed 's/^v//' | head -n 1 | awk -F'.' '{print $$1"."$$2"."$$3+1}')

release_finish:
	git flow release finish "$$(git branch --show-current | sed 's/release\///')" && git push origin develop && git push origin master && git push --tags && git checkout develop

hotfix_finish:
	git flow hotfix finish "$$(git branch --show-current | sed 's/hotfix\///')" && git push origin develop && git push origin master && git push --tags && git checkout develop

things_clean:
	git clean --exclude=!.env -Xdf
