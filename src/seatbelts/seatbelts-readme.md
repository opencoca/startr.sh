# Seatbelts 🔒

> A low-touch, unintrusive security auditor for macOS.

Seatbelts is a security auditing tool designed for macOS that runs as a Bats test suite and pushes results to a Git repository. When tests fail, it mentions the user in commit messages, triggering GitHub notifications.

## Features

- **Low-touch**: Runs in the background without interrupting your workflow
- **Powerful**: Audits a wide range of security settings across system, application, and network domains
- **Unintrusive**: Respects your workflow by allowing exceptions for required features
- **Alerting**: Triggers GitHub notifications when security issues are found
- **Customizable**: Easily extend with new tests or modify existing ones

## Installation

### Quick Install

```bash
curl -sSL https://startr.sh/Seatbelts/install | bash
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/startr-sh/seatbelts.git ~/.seatbelts
```

2. Run the installer:
```bash
cd ~/.seatbelts
./install.sh
```

## Usage

### Basic Commands

```bash
# Run all security checks and push results to GitHub
seatbelts

# Run checks only (no GitHub push)
seatbelts --run

# Push latest results to GitHub
seatbelts --push

# Configure GitHub integration
seatbelts --configure
```

### Command-line Options

```
Usage: seatbelts [OPTION]
Run security audit on macOS system.

Options:
  --help, -h     Display this help message
  --version, -v  Display version information
  --configure    Configure Seatbelts settings
  --run          Run tests only (no push to GitHub)
  --push         Push latest results to GitHub
```

## Configuration

Seatbelts understands that certain security features may need to be disabled for your workflow. You can configure these exceptions in `~/.config/seatbelts/config.yml`:

```yaml
# Seatbelts configuration
# Add features or services that are required for your workflow

required_features:
  - "SSH"
  - "Bluetooth"
  # - "Java Runtime"
  - "VPN"
```

## Test Categories

Seatbelts runs security checks across three main categories:

### System Security

- FileVault encryption
- Firewall settings
- Gatekeeper status
- Login security
- System updates
- Guest account status
- System Integrity Protection

### Application Security

- Browser security settings
- Plugin security
- Application updates
- Browser extensions

### Network Security

- Wireless security
- Bluetooth status
- DNS settings
- Firewall rules
- Network services

## Output

Seatbelts generates Markdown reports with test results that look like this:

```markdown
# Seatbelts Security Audit Report

*Generated on 2025-05-09 at 10:15:32*

This report contains results of automated security checks for your macOS system.

## Summary

* **Total Tests:** 35
* **Passed:** 33 ✅
* **Failed:** 2 ❌
* **Skipped:** 0 ⏭️

## System Security

### 1. FileVault disk encryption is enabled

**Status:** ✅ PASSED

### 2. System Firewall is enabled

**Status:** ❌ FAILED

```

## Extending Seatbelts

You can add your own tests by creating new `.bats` files in the `tests` directory. Use the helper functions provided in `lib/test_helper.bash` to ensure consistency.

## GitHub Integration

Seatbelts pushes test results to a GitHub repository and mentions you in commit messages when tests fail. This triggers GitHub notifications, ensuring you're aware of security issues.

To configure GitHub integration:

```bash
seatbelts --configure
```

## License

MIT License

## Contact

For questions or contributions, please open an issue on GitHub or visit [startr.sh/Seatbelts](https://startr.sh/Seatbelts).
