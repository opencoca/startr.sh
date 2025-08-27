#!/usr/bin/env bats
#
# Application Security Tests
#

load "../lib/test_helper"

@test "Safari doesn't automatically open 'safe' files" {
  run check_setting "defaults read com.apple.Safari AutoOpenSafeDownloads 2>/dev/null || echo '0'" "0"
  assert_success
}

@test "Safari warnings about fraudulent websites are enabled" {
  run check_setting "defaults read com.apple.Safari WarnAboutFraudulentWebsites 2>/dev/null || echo '1'" "1" 
  assert_success
}

@test "Safari JavaScript enabled only if required" {
  if is_feature_required "Safari JavaScript"; then
    skip "JavaScript in Safari is marked as required"
  fi
  run check_setting "defaults read com.apple.Safari WebKitJavaScriptEnabled 2>/dev/null || echo '0'" "0"
  assert_success
}

@test "Safari Java plug-in is disabled" {
  run check_setting "defaults read com.apple.Safari WebKitJavaEnabled 2>/dev/null || echo '0'" "0"
  assert_success
}

@test "Google Chrome Safe Browsing is enabled" {
  if ! app_is_installed "Google Chrome"; then
    skip "Google Chrome is not installed"
  fi
  
  run check_setting "defaults read com.google.Chrome SafeBrowsingEnabled 2>/dev/null || echo '1'" "1"
  assert_success
}

@test "Firefox Safe Browsing is enabled" {
  if ! app_is_installed "Firefox"; then
    skip "Firefox is not installed"
  fi
  
  # This is a simplified check - Firefox prefs are more complex
  FIREFOX_PREFS=$(find ~/Library/Application\ Support/Firefox/Profiles -name "prefs.js" | head -n 1)
  if [ -z "$FIREFOX_PREFS" ]; then
    skip "Firefox preferences file not found"
  fi
  
  run bash -c "grep -q 'safebrowsing.enabled.*false' \"$FIREFOX_PREFS\""
  assert_failure  # Failure means the setting wasn't found as disabled
}

@test "Java is not installed unless required" {
  if is_feature_required "Java Runtime"; then
    skip "Java Runtime is marked as required"
  fi
  
  run bash -c "java -version 2>&1 | grep -q 'command not found'"
  assert_success
}

@test "Flash Player is not installed unless required" {
  if is_feature_required "Flash Player"; then
    skip "Flash Player is marked as required"
  fi
  
  run bash -c "[ ! -d \"/Library/Internet Plug-Ins/Flash Player.plugin\" ]"
  assert_success
}

@test "All installed applications are up to date" {
  # Check Mac App Store apps
  run bash -c "softwareupdate -l | grep -q 'No new software available.'"
  assert_success
  
  # We're only checking presence of update tools for these package managers
  if command -v brew &>/dev/null; then
    run bash -c "brew outdated | wc -l | tr -d ' '"
    assert_output "0"
  fi
  
  if command -v mas &>/dev/null; then
    run bash -c "mas outdated | wc -l | tr -d ' '"
    assert_output "0"
  fi
}

@test "No suspicious browser extensions in Chrome" {
  if ! app_is_installed "Google Chrome"; then
    skip "Google Chrome is not installed"
  fi
  
  CHROME_EXTENSIONS_DIR="$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
  if [ ! -d "$CHROME_EXTENSIONS_DIR" ]; then
    skip "Chrome extensions directory not found"
  fi
  
  # This is a simplified check - in production you'd want a list of approved extensions
  run bash -c "ls -la \"$CHROME_EXTENSIONS_DIR\" | wc -l | tr -d ' '"
  # 3 or fewer entries means only '.', '..' and maybe one extension
  assert_output_lte 3
}

@test "No suspicious browser extensions in Firefox" {
  if ! app_is_installed "Firefox"; then
    skip "Firefox is not installed"
  fi
  
  FIREFOX_PROFILE=$(find ~/Library/Application\ Support/Firefox/Profiles -name "*.default*" | head -n 1)
  if [ -z "$FIREFOX_PROFILE" ]; then
    skip "Firefox profile not found"
  fi
  
  FIREFOX_EXTENSIONS_DIR="$FIREFOX_PROFILE/extensions"
  if [ ! -d "$FIREFOX_EXTENSIONS_DIR" ]; then
    skip "Firefox extensions directory not found"
  fi
  
  # This is a simplified check - in production you'd want a list of approved extensions
  run bash -c "ls -la \"$FIREFOX_EXTENSIONS_DIR\" | wc -l | tr -d ' '"
  # 3 or fewer entries means only '.', '..' and maybe one extension
  assert_output_lte 3
}
