#!/usr/bin/env bats
#
# Network Security Tests
#

load "../lib/test_helper"

@test "AirDrop is disabled unless required" {
  if is_feature_required "AirDrop"; then
    skip "AirDrop is marked as required"
  fi
  
  run check_setting "defaults read com.apple.NetworkBrowser DisableAirDrop 2>/dev/null || echo '0'" "1"
  assert_success
}

@test "Bluetooth is disabled unless required" {
  if is_feature_required "Bluetooth"; then
    skip "Bluetooth is marked as required"
  fi
  
  run bash -c "blueutil -p 2>/dev/null || defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null || echo '0'"
  assert_output "0"
}

@test "Wi-Fi is disabled when Ethernet is connected" {
  # Check if Ethernet is connected
  ETHERNET_STATUS=$(ifconfig en0 2>/dev/null | grep "status: active" || echo "inactive")
  if [[ "$ETHERNET_STATUS" == "inactive" ]]; then
    skip "Ethernet is not connected"
  fi
  
  # Check if Wi-Fi is disabled
  WIFI_STATUS=$(networksetup -getairportpower en1 2>/dev/null | grep "Off" || echo "On")
  run echo "$WIFI_STATUS"
  assert_output "Off"
}

@test "Automatic joining of Wi-Fi networks is disabled" {
  run check_setting "defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences RememberRecentNetworks 2>/dev/null || echo '0'" "0"
  assert_success
}

@test "Personal Hotspot is disabled unless required" {
  if is_feature_required "Personal Hotspot"; then
    skip "Personal Hotspot is marked as required"
  fi
  
  run check_setting "defaults read /Library/Preferences/SystemConfiguration/com.apple.InterfaceNamer.plist TetherInterface 2>/dev/null || echo 'disabled'" "disabled"
  assert_success
}

@test "VPN is configured and active" {
  if ! is_feature_required "VPN"; then
    skip "VPN is not marked as required"
  fi
  
  run bash -c "scutil --nc list | grep -q '* (Connected)'"
  assert_success
}

@test "No unauthorized wireless networks saved" {
  # This is a simplified check - in production you'd want a list of authorized networks
  AUTHORIZED_NETWORKS=("CompanyWiFi" "CompanyGuest")
  
  # Get list of preferred wireless networks
  SAVED_NETWORKS=$(networksetup -listpreferredwirelessnetworks en0 | grep -v "Preferred networks on en0:" || echo "")
  
  # Check each saved network against authorized list
  for network in $SAVED_NETWORKS; do
    AUTHORIZED=0
    for auth_net in "${AUTHORIZED_NETWORKS[@]}"; do
      if [[ "$network" == "$auth_net" ]]; then
        AUTHORIZED=1
        break
      fi
    done
    
    if [[ $AUTHORIZED -eq 0 ]]; then
      fail "Unauthorized network found: $network"
    fi
  done
  
  # If we made it here, all networks are authorized
  assert_success
}

@test "DNS settings are not modified" {
  # This is a simplified check - in production you'd check against known good DNS servers
  EXPECTED_DNS="8.8.8.8 1.1.1.1"  # Example of authorized DNS servers
  
  run bash -c "networksetup -getdnsservers Wi-Fi | tr '\\n' ' ' | xargs"
  if [[ "$output" != "$EXPECTED_DNS" ]]; then
    fail "DNS settings have been modified"
  fi
  
  assert_success
}

@test "Firewall blocks all incoming connections" {
  run check_setting "defaults read /Library/Preferences/com.apple.alf globalstate" "2"
  assert_success
}

@test "No suspicious listening ports" {
  # List of allowed ports
  ALLOWED_PORTS=("22" "80" "443")
  
  # Get listening ports
  LISTENING_PORTS=$(lsof -i -P | grep LISTEN | awk '{print $9}' | cut -d':' -f2 || echo "")
  
  # Check each listening port against allowed list
  for port in $LISTENING_PORTS; do
    ALLOWED=0
    for allowed_port in "${ALLOWED_PORTS[@]}"; do
      if [[ "$port" == "$allowed_port" ]]; then
        ALLOWED=1
        break
      fi
    done
    
    if [[ $ALLOWED -eq 0 ]]; then
      fail "Suspicious listening port found: $port"
    fi
  done
  
  # If we made it here, all ports are allowed
  assert_success
}

@test "Hosts file has not been tampered with" {
  # This is a simplified check - in production you'd hash the file or check against a known good version
  run bash -c "wc -l /etc/hosts | awk '{print $1}'"
  assert_output_lte 15  # Most default macOS hosts files are shorter than this
}

@test "No suspicious proxy settings" {
  run bash -c "scutil --proxy | grep -q 'Enabled : 0'"
  assert_success
}
