# TODO - Startr.sh Development Tasks

## Project Philosophy & Vision

### **The Startr Enlightenment**
This project embodies a philosophy of **Radical Simplification** in software development - the belief that the most powerful tools are those that eliminate complexity rather than add it.

**Core Tenets:**
1. **Immediate Value**: Every tool should provide instant, tangible benefit (`curl | bash` and you're productive)
2. **Transparency by Design**: No black boxes - every script is human-readable and self-documenting
3. **Battle-Tested Over Bleeding-Edge**: We prefer proven patterns over innovative complexity
4. **Standards as Code**: Development conventions should be as versionable and deployable as the code itself
5. **Enlightenment Through Convention**: True freedom comes from agreed-upon constraints that eliminate decision fatigue

**The CEP Vision:**
Common Enlightenment Protocol represents our belief that development teams spend too much time reinventing basic project conventions. CEP asks: "What if following best practices was as easy as running a single command?"

**Philosophical Opposition:**
- Against "Configuration Hell" - endless setup before productivity
- Against "Framework Lock-in" - tools should enhance, not control
- Against "Documentation Rot" - living documentation that stays current with practice
- Against "Tribal Knowledge" - conventions should be explicit and transferable

### **[PHILOSOPHY IMPLEMENTATION] Living Philosophy Documentation**
- [ ] **Create Philosophy Documentation**: Articulate and formalize project beliefs
  - [ ] Create `docs/philosophy/` directory for philosophical documentation
  - [ ] Document "Radical Simplification" principles with examples
  - [ ] Create manifesto explaining anti-patterns we actively oppose
  - [ ] Document decision-making framework based on core tenets
  - [ ] Add philosophy section to main README.md
  - [ ] Create examples showing philosophy in practice
  - [ ] Link philosophy to technical decisions in codebase

- [ ] **Philosophy-Driven Development Guidelines**: Ensure all code follows philosophy
  - [ ] Create code review checklist based on core tenets
  - [ ] Document how to evaluate new features against philosophy
  - [ ] Create rejection criteria for complexity-adding proposals
  - [ ] Add philosophy validation to automated testing
  - [ ] Document how to explain philosophy to new contributors
  - [ ] Create philosophy-based troubleshooting guides

## Documentation & Resource Sharing TODOs

### **[DOCUMENTATION] SEO and Site Structure Optimization**
- [x] **Reorganize Marketing Documentation**: Move content to appropriate src docs structure
  - [x] Create `src/docs/` directory for site documentation
  - [x] Rename `docs/why.md` to SEO-friendly name (`startr-benefits-for-development-teams.md`)
  - [ ] Move marketing content from repo docs to src docs
  - [ ] Update navigation and internal links
  - [ ] Verify SEO optimization of new structure
  - [ ] Test that content is properly served by site

### **[CEP] Common Enlightenment Protocol Implementation**
- [x] **Create CEP Directory Structure**: Set up Common Enlightenment Protocol folder
  - [x] Create `src/cep/` directory for CEP resources
  - [x] Create hard links to `CONVENTION.instructions.md` in CEP folder
  - [x] Create hard links to `docs/DEVELOPMENT_WORKFLOW.md` in CEP folder
  - [x] Test hard link functionality and maintenance
  - [x] Verify file synchronization between original and CEP copies
  - [x] Create Makefile targets for CEP hard link management (`cep_fix_links`, `cep_status`)
  - [x] Create git post-checkout hook for automatic hard link recreation
  - [x] Add hook installation targets (`install_hooks`, `uninstall_hooks`)
  - [x] Test automated hard link restoration after git operations

- [ ] **Create CEP Index Script/Page**: Dual-purpose deployment and explanation
  - [ ] Design `src/cep/index.njk` following `src/index.njk` pattern
  - [ ] Create CEP deployment script functionality (bash section)
  - [ ] Create CEP explanation page (HTML section)
  - [ ] Follow `_includes/home_page.njk` structure for page layout
  - [ ] Implement script that deploys CEP files to target projects
  - [ ] Add interactive options for CEP deployment
  - [ ] Test both script and page functionality

- [ ] **Create CEP Page Template**: Following established patterns
  - [ ] Create `src/cep/_includes/cep_page.njk` template
  - [ ] Design CEP branding and visual identity
  - [ ] Add explanation of Common Enlightenment Protocol concepts
  - [ ] Include usage examples and best practices
  - [ ] Add download/deployment instructions
  - [ ] Create responsive design following site standards
  - [ ] Test page rendering and functionality

- [ ] **CEP Deployment Logic**: Script functionality for project setup
  - [ ] Implement file detection and project analysis
  - [ ] Add CEP file deployment to target directories
  - [ ] Create backup mechanism for existing files
  - [ ] Add conflict resolution for existing conventions
  - [ ] Implement verification and validation checks
  - [ ] Add rollback functionality for failed deployments
  - [ ] Test deployment across different project types
  - [ ] Create deployment logging and reporting

- [ ] **Research Eleventy Includes Optimization**: Improve CEP self-containment
  - [ ] Research 11ty documentation for local includes configuration
  - [ ] Investigate options to keep CEP includes within `src/cep/` folder
  - [ ] Test alternative include paths and configurations
  - [ ] Evaluate benefits of self-contained vs shared includes approach
  - [ ] Implement optimized include structure if beneficial
  - [ ] Update CEP template structure based on findings
  - [ ] Document best practices for future reference

### **[DOCUMENTATION] Standardized Makefile Documentation**
- [x] **Create docs/ directory structure**: Set up comprehensive documentation folder
  - [x] Create `docs/` directory
  - [x] Create `docs/makefile/` subdirectory for Makefile-specific docs
  - [x] Create `docs/development/` subdirectory for dev workflow docs
  - [x] Create `docs/examples/` subdirectory for usage examples
  - [x] Test documentation structure accessibility
  - [x] Update main README.md to reference new docs structure

- [x] **Document Standardized Makefile Features**: Comprehensive Makefile documentation
  - [x] Create `docs/makefile/README.md` - Main Makefile documentation
  - [x] Create `docs/makefile/commands.md` - Detailed command reference
  - [x] Create `docs/makefile/variables.md` - Dynamic variables explanation
  - [ ] Create `docs/makefile/deployment.md` - CapRover deployment docs
  - [ ] Create `docs/makefile/git-flow.md` - Git flow integration docs
  - [ ] Create `docs/makefile/customization.md` - How to customize the Makefile
  - [x] Test all documented commands work as expected
  - [x] Add troubleshooting section to each doc

- [x] **Create Development Workflow Documentation**: Following CONVENTION.instructions.md
  - [x] Create `docs/development/DEVELOPMENT_WORKFLOW.md` 
  - [x] Document Plan-Document-Execute-Verify cycle
  - [x] Document SOLID, YAGNI, KISS, DRY principles application
  - [x] Create development setup guide
  - [x] Document testing procedures
  - [x] Documentation update procedures

### **[RESOURCE SHARING] Enhanced Startr.sh Resource Distribution**
- [ ] **Create Resource Download System**: Help users get standard files
  - [ ] Design resource endpoint structure (`/resources/makefile`, `/resources/dockerfile`, etc.)
  - [ ] Create `src/resources/` directory for downloadable resources
  - [ ] Add standardized Makefile to downloadable resources
  - [ ] Add standardized Dockerfile templates to resources
  - [ ] Add standardized .gitignore templates to resources
  - [ ] Add standardized .env.example templates to resources
  - [ ] Test resource download functionality
  - [ ] Add version tracking for resources

- [ ] **Enhance Startr.sh Script**: Add resource download capabilities
  - [ ] Modify main startr.sh script to offer resource downloads
  - [ ] Add `--get-makefile` flag to download standardized Makefile
  - [ ] Add `--get-dockerfile` flag to download appropriate Dockerfile
  - [ ] Add `--get-gitignore` flag to download appropriate .gitignore
  - [ ] Add `--setup-project` flag for complete project setup
  - [ ] Add interactive mode for resource selection
  - [ ] Test all new flags and functionality
  - [ ] Update help text and documentation

- [ ] **Create Resource Templates**: Standardized project templates
  - [ ] Create template Makefiles for different project types (web, api, desktop)
  - [ ] Create template Dockerfiles for different frameworks (Node.js, Python, etc.)
  - [ ] Create template package.json files
  - [ ] Create template .env.example files
  - [ ] Create template .gitignore files
  - [ ] Create template CI/CD configurations
  - [ ] Test templates with various project types
  - [ ] Version control all templates

### **[WEB INTERFACE] Documentation Integration**
- [ ] **Add Documentation Section to Website**: Make docs easily accessible
  - [ ] Create documentation navigation in main site
  - [ ] Add "Documentation" button functionality (currently hidden)
  - [ ] Create documentation index page
  - [ ] Add search functionality for documentation
  - [ ] Create mobile-friendly documentation layout
  - [ ] Add syntax highlighting for code examples
  - [ ] Test documentation accessibility
  - [ ] Add feedback mechanism for documentation

- [ ] **Create Interactive Examples**: Live demos and examples
  - [ ] Create interactive Makefile command examples
  - [ ] Add copy-to-clipboard functionality for commands
  - [ ] Create project setup wizard
  - [ ] Add visual flowcharts for development workflow
  - [ ] Create troubleshooting interactive guide
  - [ ] Test interactive examples across browsers
  - [ ] Add analytics for most-used examples

### **[TESTING & VALIDATION] Quality Assurance**
- [ ] **Test Resource Distribution**: Ensure everything works
  - [ ] Test Makefile download and functionality
  - [ ] Test Dockerfile templates with various projects
  - [ ] Test documentation accuracy and completeness
  - [ ] Test website documentation integration
  - [ ] Test mobile responsiveness of documentation
  - [ ] Validate all links and references
  - [ ] Performance test resource downloads
  - [ ] Cross-browser testing for web interface

- [ ] **Create Automated Testing**: Continuous validation
  - [ ] Create tests for Makefile commands
  - [ ] Create tests for resource downloads
  - [ ] Create tests for documentation completeness
  - [ ] Create tests for website functionality
  - [ ] Set up CI/CD for documentation updates
  - [ ] Add automated link checking
  - [ ] Test documentation build process
  - [ ] Add automated accessibility testing

## Implementation Priority

**Phase 0: CEP Foundation (Current Sprint)**
- Create CEP directory structure with hard links
- Design and implement CEP index.njk (script + page)
- Create CEP page template following established patterns
- Implement basic CEP deployment functionality

**Phase 1: Foundation (Week 1)**
- Create docs/ directory structure
- Create basic Makefile documentation
- Create DEVELOPMENT_WORKFLOW.md

**Phase 2: Resource System (Week 2)**
- Create resource download system
- Enhance startr.sh script with download flags
- Create standardized templates
- Complete CEP deployment logic and testing

**Phase 3: Web Integration (Week 3)**
- Integrate documentation into website
- Add interactive examples
- Enable documentation navigation
- Add CEP access from main site

**Phase 4: Testing & Polish (Week 4)**
- Comprehensive testing
- Automated testing setup
- Performance optimization
- Final documentation review
- CEP validation and refinement

## Notes
- Follow CONVENTION.instructions.md for all development
- Update this TODO.md as work progresses
- Check off completed items
- Add new tasks as discovered during implementation
- **CEP Hard Links**: Git operations (checkout, reset) break hard links by creating new files
  - Use `make cep_fix_links` to manually restore hard links
  - Use `make cep_status` to check hard link status
  - Use `make install_hooks` to enable automatic restoration via git post-checkout hook
  - Hook automatically runs after `git checkout` operations
