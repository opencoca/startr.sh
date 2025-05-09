---
layout: base
title: Startr.sh Seatbelts 
---


# Seatbelts, a security auditor for macOS.

![Seatbelts](/assets/SEATBELTS_Logo.jpg)

Seatbelts - System Overview
Seatbelts is a "low touch" security auditor for macOS that runs as a Bats test suite. Here's how the components work together:

Core Script (seatbelts.sh):

The main entry point that coordinates test execution
Handles command-line arguments and configuration
Manages result output and GitHub integration


Test Suites:

tests/system_security.bats: Core system security settings
tests/application_security.bats: Application security settings
tests/network_security.bats: Network-related security settings
tests/custom_security.bats: Template for custom organizational tests


Support Libraries:

lib/test_helper.bash: Shared functions used across tests
lib/formatters/markdown.js: Formats test results as Markdown


Installation & Configuration:

install.sh: Sets up the entire system with dependencies
config.yml: Configuration file for customizing tests and notifications


Documentation:

README.md: Comprehensive project documentation



Key Features

Low Touch Design:

Runs silently in the background via cron jobs
Only alerts when there are issues (failing tests)


GitHub Integration:

Results are pushed to a Git repository
Failed tests trigger GitHub notifications by mentioning the user
This creates a lightweight alerting mechanism without additional infrastructure


Highly Configurable:

Tests can be exempted based on your workflow needs
Custom tests can be added easily


DRY (Don't Repeat Yourself):

Common testing functions are centralized in test_helper.bash
Test patterns are consistent across different security domains


Extensible:

The Bats framework makes it easy to add new tests
The modular design separates concerns properly



How to Use

Install using either the provided installer or manually
Configure required features in the config file
Add any custom tests specific to your environment
Let it run automatically, or trigger manually with seatbelts command