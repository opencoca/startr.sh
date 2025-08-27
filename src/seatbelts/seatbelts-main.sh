#!/usr/bin/env bash
#
# Seatbelts - Low touch security auditor for macOS
# https://startr.sh/Seatbelts
#

set -e

SEATBELTS_VERSION="0.1.0"
SEATBELTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SEATBELTS_DIR}/results"
CONFIG_FILE="${SEATBELTS_DIR}/config.yml"
GITHUB_USERNAME=""

# Load configuration if exists
if [ -f "${CONFIG_FILE}" ]; then
  # Simple YAML parsing - can be expanded for more complex configs
  GITHUB_USERNAME=$(grep "github_username:" "${CONFIG_FILE}" | cut -d':' -f2 | tr -d ' ')
fi

# Create results directory if it doesn't exist
mkdir -p "${RESULTS_DIR}"

# Generate timestamp for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_FILE="${RESULTS_DIR}/audit_${TIMESTAMP}.md"

# Print banner
echo "==============================================="
echo "🔒 Seatbelts v${SEATBELTS_VERSION}"
echo "    Low touch security auditor for macOS"
echo "==============================================="

# Function to run all tests
run_tests() {
  echo "Running security tests..."
  
  # Run bats tests and capture output
  "${SEATBELTS_DIR}/bats/bin/bats" \
    --formatter "${SEATBELTS_DIR}/lib/formatters/markdown.js" \
    "${SEATBELTS_DIR}/tests" > "${RESULTS_FILE}"
  
  # Count failures
  FAILURES=$(grep -c "❌" "${RESULTS_FILE}" || true)
  
  echo "Tests completed with ${FAILURES} failures."
  echo "Results saved to: ${RESULTS_FILE}"
  
  return ${FAILURES}
}

# Function to commit and push results to GitHub
push_results() {
  if [ -z "${GITHUB_USERNAME}" ]; then
    echo "GitHub username not configured. Skipping push to repository."
    return 0
  fi
  
  echo "Pushing results to repository..."
  
  # Enter results directory
  cd "${RESULTS_DIR}"
  
  # Initialize git repository if not already present
  if [ ! -d ".git" ]; then
    git init
    git config user.name "Seatbelts Auditor"
    git config user.email "seatbelts@noreply.github.com"
    git remote add origin "https://github.com/${GITHUB_USERNAME}/seatbelts-results.git"
  fi
  
  # Add results files
  git add "${RESULTS_FILE}"
  
  # Commit with @mention for notifications if there are failures
  if [ ${FAILURES} -gt 0 ]; then
    git commit -m "Security audit failed with ${FAILURES} issues @${GITHUB_USERNAME}"
  else
    git commit -m "Security audit passed"
  fi
  
  # Push to GitHub
  git push -u origin master || echo "Failed to push to GitHub. Please check your credentials and repository."
}

# Parse command line arguments
case "$1" in
  --version|-v)
    echo "Seatbelts v${SEATBELTS_VERSION}"
    exit 0
    ;;
  --help|-h)
    echo "Usage: $0 [OPTION]"
    echo "Run security audit on macOS system."
    echo ""
    echo "Options:"
    echo "  --help, -h     Display this help message"
    echo "  --version, -v  Display version information"
    echo "  --configure    Configure Seatbelts settings"
    echo "  --run          Run tests only (no push to GitHub)"
    echo "  --push         Push latest results to GitHub"
    echo ""
    exit 0
    ;;
  --configure)
    echo "Configuring Seatbelts..."
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    echo "github_username: ${GITHUB_USERNAME}" > "${CONFIG_FILE}"
    echo "Configuration saved to ${CONFIG_FILE}"
    exit 0
    ;;
  --run)
    run_tests
    exit $?
    ;;
  --push)
    # Just push the most recent results
    LATEST_RESULTS=$(ls -t "${RESULTS_DIR}"/*.md | head -n1)
    FAILURES=$(grep -c "❌" "${LATEST_RESULTS}" || true)
    push_results
    exit 0
    ;;
  *)
    # Default: run tests and push results
    run_tests
    push_results
    exit $?
    ;;
esac
