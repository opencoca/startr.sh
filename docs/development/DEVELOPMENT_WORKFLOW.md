# Development Workflow

> Following the **Plan-Document-Execute-Verify** cycle with SOLID principles.

## Core Principles

### 0. Zeroth Principle: **Follow the Standards**
- **SOLID** - Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **YAGNI** - You Aren't Gonna Need It (don't add features until needed)
- **KISS** - Keep It Simple, Stupid
- **DRY** - Don't Repeat Yourself (ever in Code)

### 1. **Plan** - Add to TODO.md before doing any work
### 2. **Document** - Update docs and README as needed  
### 3. **Execute** - Implement changes following standards
### 4. **Verify** - Test, commit, and check off completed items

## Standard Operating Procedure

### Before Starting Any Work

**ALWAYS add to TODO.md first:**

```markdown
## [Category] TODOs
- [ ] **[Task Name]**: Brief description
  - [ ] Subtask 1
  - [ ] Subtask 2  
  - [ ] Test/verify step
  - [ ] Documentation update
```

**NEVER start work without:**
- Adding the task to TODO.md
- Getting approval for significant changes
- Understanding the complete scope

### Planning Requirements

For each task, define:
- **Scope** - What exactly needs to be done
- **Dependencies** - What must be completed first
- **Testing** - How to verify it works
- **Documentation** - What docs need updates

## Workflow Example

### ✅ Correct Approach

1. **Plan**: Add to TODO.md
   ```markdown
   ## [FEATURE] Add Resource Download System
   - [ ] **Create /resources endpoint**: Allow downloading standard files
     - [ ] Create src/resources/ directory
     - [ ] Add Makefile to downloadable resources
     - [ ] Test download functionality
     - [ ] Update documentation
   ```

2. **Document**: Update relevant docs
   - Update API documentation
   - Add usage examples
   - Update README if needed

3. **Execute**: Implement following standards
   - Single responsibility per function
   - DRY - reuse existing utilities
   - KISS - keep the implementation simple
   - YAGNI - only build what's needed

4. **Verify**: Test and validate
   - Test the feature works
   - Check all related functionality still works
   - Commit changes
   - Check off TODO items

### ❌ Wrong Approach

- Starting to code without planning
- Making changes without updating docs
- Adding features "just in case" (YAGNI violation)
- Copying code instead of creating reusable functions (DRY violation)

## Code Standards

### File Organization

```
src/
├── _includes/           # Reusable template components
├── _data/              # Data files
├── _plugins/           # Custom Eleventy plugins
├── assets/             # Static assets
└── index.njk           # Main page/script (Single Responsibility)
```

### Function Design (SOLID)

#### Single Responsibility
```javascript
// ✅ Good - single purpose
function downloadMakefile() {
  return fetch('/resources/makefile');
}

// ❌ Bad - multiple responsibilities  
function downloadAndInstallMakefile() {
  // Downloads AND installs - violates SRP
}
```

#### Open/Closed Principle
```javascript
// ✅ Good - open for extension, closed for modification
class ResourceDownloader {
  download(type) {
    return this.getDownloadStrategy(type).download();
  }
  
  getDownloadStrategy(type) {
    // Can add new types without modifying existing code
  }
}
```

#### DRY Principle
```javascript
// ✅ Good - reusable utility
function createDownloadLink(resource, filename) {
  return `<a href="/resources/${resource}" download="${filename}">Download ${filename}</a>`;
}

// ❌ Bad - repeated code
function createMakefileLink() {
  return '<a href="/resources/makefile" download="Makefile">Download Makefile</a>';
}
function createDockerfileLink() {
  return '<a href="/resources/dockerfile" download="Dockerfile">Download Dockerfile</a>';
}
```

## Testing Standards

### Before Committing
- [ ] All existing functionality still works
- [ ] New functionality works as expected
- [ ] Documentation is updated
- [ ] TODO.md is updated with progress

### Testing Checklist
```bash
# Build the project
make it_build

# Test the website locally
npm run dev

# Test the script functionality
bash <(curl -sL localhost:8080)

# Verify documentation builds
# (Add documentation build command when available)
```

## Git Workflow

### Branch Naming
- `feature/resource-download-system`
- `fix/makefile-variable-extraction`
- `docs/update-api-documentation`

### Commit Messages
```bash
# ✅ Good - clear and specific
git commit -m "Add resource download endpoint for Makefile

- Create /resources/makefile route
- Add downloadable Makefile template
- Update documentation with usage examples
- Closes #123"

# ❌ Bad - vague
git commit -m "Add stuff"
```

### Git Flow Integration
```bash
# Start feature
make minor_release  # or patch_release, major_release

# Work on feature following Plan-Document-Execute-Verify

# Finish feature  
make release_finish
```

## Documentation Standards

### Structure
- **Clear headings** with hierarchy
- **Code examples** for everything
- **Quick reference** sections
- **Troubleshooting** for common issues

### Writing Style
- **Concise** - no unnecessary words
- **Clear** - avoid jargon
- **Complete** - include all necessary information
- **Consistent** - follow established patterns

### Example Documentation Template
```markdown
# Feature Name

> Brief description in one sentence.

## Quick Start
\`\`\`bash
# Most common usage
command --example
\`\`\`

## Overview
Brief explanation of what this does and why.

## Configuration
How to set it up.

## Examples
Real-world usage examples.

## Troubleshooting
Common issues and solutions.
```

## Project-Specific Guidelines

### Startr.sh Dual Nature
Remember that `src/index.njk` is both:
- **HTML template** for the landing page
- **Bash script** that becomes startr.sh

When editing:
- Keep the script functional and clean
- Ensure HTML structure remains valid
- Test both website and script functionality

### Makefile Integration
- Always test new features with both `make` commands and direct startr.sh calls
- Ensure dynamic variable extraction works correctly
- Test with different project structures

### Resource Management
- Keep downloadable resources in sync with actual implementations
- Version control all templates
- Test download functionality after changes

## Troubleshooting Development Issues

### Common Problems

**"Make command not working"**
- Check if you're in project root
- Verify Git repository is initialized
- Run `make show_vars` to debug variables

**"Documentation not building"**
- Check for Markdown syntax errors
- Verify all links are valid
- Ensure file paths are correct

**"Script/website out of sync"**
- Remember both are generated from `src/index.njk`
- Test both after changes
- Verify the build process completed

### Getting Help
1. Check existing documentation
2. Search closed issues on GitHub
3. Ask in team discussions
4. Create detailed issue with reproduction steps

---

*This workflow ensures consistent, high-quality development following industry best practices.*
