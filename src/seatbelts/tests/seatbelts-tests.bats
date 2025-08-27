#!/usr/bin/env bats
#
# Core System Security Tests
#

load "../lib/test_helper"

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

@test "FileVault disk encryption is enabled" {
  run bash -c "fdesetup status | grep -q 'FileVault is On'"
  assert_success
}

@test "System Firewall is enabled" {
  run check_setting "defaults read /Library/Preferences/com.apple.alf globalstate" "1"
  assert_success
}

@test "Gatekeeper is enabled" {
  run bash -c "spctl --status | grep -q 'assessments enabled'"
  assert_success
}

@test "Auto-login is disabled" {
  run check_setting "defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || echo 'disabled'" "disabled"
  assert_success
}

@test "Password is required after sleep or screen saver" {
  run check_setting "defaults read com.apple.screensaver askForPassword" "1"
  assert_success
}

@test "Screensaver timeout is set to 5 minutes or less" {
  run bash -c "idle_time=\$(defaults read com.apple.screensaver idleTime); [[ \$idle_time -le 300 ]] && echo '1' || echo '0'"
  assert_output "1"
}

@test "Remote Login (SSH) is disabled unless required" {
  if is_service_required "SSH"; then
    skip "SSH is marked as required service"
  fi
  run bash -c "systemsetup -getremotelogin | grep -q 'Remote Login: Off'"
  assert_success
}

@test "Remote Apple Events are disabled" {
  run bash -c "systemsetup -getremoteappleevents | grep -q 'Remote Apple Events: Off'"
  assert_success
}

@test "Automatic OS updates are enabled" {
  run check_setting "defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled" "1"
  assert_success
}

@test "System is updated to the latest security patches" {
  # This is a simplified check - in production, you'd want more sophisticated version checking
  run bash -c "softwareupdate -l | grep -q 'No new software available.'"
  assert_success
}

@test "Guest user account is disabled" {
  run check_setting "defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null || echo '0'" "0"
  assert_success
}

@test "SIP (System Integrity Protection) is enabled" {
  run bash -c "csrutil status | grep -q 'enabled'"
  assert_success
}

@test "Secure keyboard entry in Terminal is enabled" {
  run check_setting "defaults read -app Terminal SecureKeyboardEntry" "1"
  assert_success
}

@test "Firewall stealth mode is enabled" {
  run check_setting "defaults read /Library/Preferences/com.apple.alf stealthenabled" "1"
  assert_success
}
