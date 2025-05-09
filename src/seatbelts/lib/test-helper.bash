#!/usr/bin/env bash
#
# Test Helper functions for Seatbelts tests
#

# Load Bats test helper
load "../bats/lib/bats-support/load"
load "../bats/lib/bats-assert/load"

# Path to Seatbelts config
SEATBELTS_CONFIG_DIR="$HOME/.config/seatbelts"
SEATBELTS_CONFIG_FILE="${SEATBELTS_CONFIG_DIR}/config.yml"

# Helper function to evaluate security settings
check_setting() {
  local command="$1"
  local expected_output="$2"
  local actual_output
  actual_output=$(eval "$command")
  
  if [[ "$actual_output" == "$expected_output" ]]; then
    return 0
  else
    return 1
  fi
}

# Check if an application is installed
app_is_installed() {
  local app_name="$1"
  [[ -d "/Applications/${app_name}.app" ]] || [[ -d "$HOME/Applications/${app_name}.app" ]]
}

# Assert output is less than or equal to a value
assert_output_lte() {
  local expected="$1"
  local actual
  
  if [[ -z "$output" ]]; then
    fail "Output is empty"
    return 1
  fi
  
  actual=$(echo "$output" | tr -d '[:space:]')
  
  if (( actual <= expected )); then
    return 0
  else
    fail "Expected output to be <= $expected, but got $actual"
    return 1
  fi
}

# Check if a feature/service is required (exempt from security check)
is_feature_required() {
  local feature_name="$1"
  
  # Create config directory if it doesn't exist
  if [[ ! -d "$SEATBELTS_CONFIG_DIR" ]]; then
    mkdir -p "$SEATBELTS_CONFIG_DIR"
  fi
  
  # Create config file with default exemptions if it doesn't exist
  if [[ ! -f "$SEATBELTS_CONFIG_FILE" ]]; then
    cat > "$SEATBELTS_CONFIG_FILE" << EOF
# Seatbelts configuration
# Add features or services that are required for your workflow

required_features:
  # - "SSH"
  # - "Bluetooth"
  # - "Java Runtime"
  # - "VPN"
EOF
  fi
  
  # Check if feature is in required_features list
  grep -q "^ *- *\"$feature_name\"" "$SEATBELTS_CONFIG_FILE" 2>/dev/null
}

# Check if a service is required (exempt from security check)
is_service_required() {
  is_feature_required "$1"
}
