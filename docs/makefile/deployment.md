# CapRover Deployment Guide

> One-command deployment with intelligent submodule handling.

## Quick Start

```bash
# Deploy to CapRover
make deploy
```

## Prerequisites

### 1. Install CapRover CLI
```bash
npm install -g caprover
```

### 2. Login to CapRover
```bash
caprover login
```

Follow the prompts to configure your CapRover instance.

### 3. Initialize CapRover App
```bash
caprover deploy
```

First deployment will prompt you to create the app.

## How `make deploy` Works

The deployment process is intelligent and handles different scenarios automatically:

### Standard Deployment (No Submodules)
```bash
# If no .gitmodules file exists
npx caprover deploy
```

### Submodule Deployment
```bash
# If .gitmodules file exists
git ls-files --recurse-submodules | tar -czf deploy.tar -T -
npx caprover deploy -t ./deploy.tar
rm ./deploy.tar
```

## Project Configuration

### captain-definition File
Create `captain-definition` in your project root:

```json
{
  "schemaVersion": 2,
  "dockerfilePath": "./Dockerfile"
}
```

### Environment Variables
Set in CapRover dashboard or via CLI:

```bash
# Set environment variables
caprover deploy --envVar NODE_ENV=production
caprover deploy --envVar DATABASE_URL=your_db_url
```

## Deployment Scenarios

### Scenario 1: Simple Web App
```bash
# Project structure
my-web-app/
├── Dockerfile
├── captain-definition
├── package.json
└── src/

# Deploy command
make deploy
```

### Scenario 2: Project with Submodules
```bash
# Project structure  
my-complex-app/
├── .gitmodules
├── Dockerfile
├── captain-definition
├── backend/         # submodule
└── frontend/        # submodule

# Deploy command (automatically creates tar)
make deploy
```

### Scenario 3: Monorepo
```bash
# Project structure
my-monorepo/
├── Dockerfile
├── captain-definition
├── services/
│   ├── api/
│   └── web/
└── shared/

# Deploy command
make deploy
```

## Advanced Configuration

### Custom Dockerfile
```bash
# Use specific Dockerfile
caprover deploy --dockerfile ./docker/production.dockerfile
```

### Build Arguments
```bash
# Pass build arguments
caprover deploy --envVar BUILD_ENV=production
```

### Pre-deployment Hooks
Add to your Dockerfile:

```dockerfile
# Install dependencies
RUN npm ci --only=production

# Build assets
RUN npm run build

# Setup production environment
ENV NODE_ENV=production
```

## Troubleshooting

### Common Issues

**"CapRover CLI is not installed"**
```bash
npm install -g caprover
# Verify installation
caprover --version
```

**"You are not logged in to CapRover"**
```bash
caprover login
# Follow the setup prompts
```

**"App not found"**
```bash
# Create app first
caprover deploy
# Follow app creation prompts
```

**"Build failed"**
- Check Dockerfile syntax
- Verify all files are included
- Check build logs in CapRover dashboard

**"Submodules not included"**
- Verify `.gitmodules` file exists
- Check submodule status: `git submodule status`
- Update submodules: `git submodule update --init --recursive`

### Debug Deployment

```bash
# Check what files will be included
git ls-files --recurse-submodules

# Test tar creation manually
git ls-files --recurse-submodules | tar -czf test.tar -T -
tar -tzf test.tar | head -20
rm test.tar

# Verbose deployment
caprover deploy --verbose
```

## Environment-Specific Deployments

### Development
```bash
# Deploy develop branch to staging
git checkout develop
make deploy
```

### Production
```bash
# Deploy main branch to production
git checkout main
make deploy
```

### Feature Testing
```bash
# Deploy feature branch to test environment
git checkout feature/new-feature
make deploy
# App name: PROJECT-new-feature
```

## Automated Deployment

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to CapRover
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: recursive
      
      - name: Deploy to CapRover
        run: |
          npm install -g caprover
          echo "${{ secrets.CAPROVER_PASSWORD }}" | caprover login
          make deploy
```

### GitLab CI
```yaml
# .gitlab-ci.yml
deploy:
  stage: deploy
  script:
    - npm install -g caprover
    - echo "$CAPROVER_PASSWORD" | caprover login
    - make deploy
  only:
    - main
```

## Best Practices

### Pre-Deployment Checklist
- [ ] Test build locally: `make it_build`
- [ ] Verify environment variables are set
- [ ] Check captain-definition is correct
- [ ] Ensure Dockerfile is optimized
- [ ] Test submodule updates if applicable

### Security
```bash
# Use environment variables for secrets
# Never commit credentials
echo ".env" >> .gitignore
echo "captain-definition" >> .gitignore  # If it contains secrets
```

### Performance
```bash
# Optimize Dockerfile
FROM node:16-alpine  # Use smaller images
RUN npm ci --only=production  # Install only production deps
COPY --chown=node:node . .  # Set proper ownership
```

### Monitoring
- Check CapRover logs after deployment
- Set up health checks
- Monitor resource usage
- Configure backup strategies

## Integration with Git Flow

```bash
# Complete release and deploy
make release_finish
git checkout main
make deploy

# Hotfix deployment
make hotfix
# ... make changes ...
make hotfix_finish
make deploy
```

---

**See also**: [Commands Reference](commands.md) | [Variables Guide](variables.md) | [Main Documentation](README.md)
