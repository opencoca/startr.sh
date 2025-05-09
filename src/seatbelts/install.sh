#!/usr/bin/env bash
#
# Seatbelts Installer
# https://startr.sh/Seatbelts
#

set -e

REPO_URL="https://github.com/startr-sh/seatbelts.git"
INSTALL_DIR="$HOME/.seatbelts"
BATS_VERSION="1.7.0"

echo "==============================================="
echo "🔒 Seatbelts Installer"
echo "    Low touch security auditor for macOS"
echo "==============================================="

# Check for git
if ! command -v git &> /dev/null; then
  echo "Error: git is required but not installed."
  echo "Please install git and try again."
  exit 1
fi

# Install dependencies
install_dependencies() {
  echo "Installing dependencies..."
  
  # Check for Homebrew
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Would you like to install it? (y/n)"
    read -r install_brew
    if [[ "$install_brew" =~ ^[Yy]$ ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo "Homebrew is required for some features. Continuing without it..."
    fi
  fi
  
  # Install blueutil for Bluetooth checks
  if command -v brew &> /dev/null && ! command -v blueutil &> /dev/null; then
    echo "Installing blueutil for Bluetooth checks..."
    brew install blueutil
  fi
  
  echo "Dependencies installed."
}

# Clone or update the repository
setup_repository() {
  if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin master
  else
    echo "Installing Seatbelts to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
  fi
}

# Install Bats testing framework
install_bats() {
  echo "Setting up Bats testing framework..."
  
  if [ -d "$INSTALL_DIR/bats" ]; then
    echo "Bats already installed, skipping..."
    return
  fi
  
  mkdir -p "$INSTALL_DIR/bats"
  
  # Download and extract Bats
  local tempdir
  tempdir=$(mktemp -d)
  cd "$tempdir"
  
  echo "Downloading Bats v${BATS_VERSION}..."
  curl -L -o bats.tar.gz "https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz"
  tar -xzf bats.tar.gz
  
  # Install Bats
  cd "bats-core-${BATS_VERSION}"
  ./install.sh "$INSTALL_DIR/bats"
  
  # Install Bats libraries
  cd "$INSTALL_DIR"
  mkdir -p bats/lib
  
  # Install bats-support
  git clone https://github.com/bats-core/bats-support.git bats/lib/bats-support
  
  # Install bats-assert
  git clone https://github.com/bats-core/bats-assert.git bats/lib/bats-assert
  
  echo "Bats testing framework installed."
}

# Set up cron job for regular security checks
setup_cron() {
  echo "Setting up scheduled security checks..."
  
  # Create cron job for daily checks
  (crontab -l 2>/dev/null || echo "") | grep -v "seatbelts.sh" | \
    { cat; echo "0 9 * * * $INSTALL_DIR/seatbelts.sh --run > /dev/null 2>&1"; } | \
    crontab -
  
  # Create cron job for weekly GitHub push
  (crontab -l 2>/dev/null || echo "") | grep -v "seatbelts.sh --push" | \
    { cat; echo "0 10 * * 1 $INSTALL_DIR/seatbelts.sh --push > /dev/null 2>&1"; } | \
    crontab -
  
  echo "Scheduled security checks have been set up."
}

# Create configuration directory
setup_config() {
  echo "Setting up configuration..."
  
  CONFIG_DIR="$HOME/.config/seatbelts"
  CONFIG_FILE="$CONFIG_DIR/config.yml"
  
  mkdir -p "$CONFIG_DIR"
  
  if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# Seatbelts configuration
# Add features or services that are required for your workflow

required_features:
  # - "SSH"
  # - "Bluetooth"
  # - "Java Runtime"
  # - "VPN"
EOF
  fi
  
  echo "Configuration directory created at $CONFIG_DIR"
}

# Create symbolic link to make command available system-wide
create_symlink() {
  echo "Making Seatbelts command available..."
  
  # Create bin directory if it doesn't exist
  mkdir -p "$HOME/bin"
  
  # Create symlink
  ln -sf "$INSTALL_DIR/seatbelts.sh" "$HOME/bin/seatbelts"
  
  # Check if PATH includes ~/bin
  if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "Adding $HOME/bin to your PATH..."
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bash_profile"
    
    # Also add to zsh profile if it exists
    if [ -f "$HOME/.zshrc" ]; then
      echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    echo "Please restart your terminal or run 'source ~/.bash_profile' to update your PATH."
  fi
  
  echo "Seatbelts command is now available as 'seatbelts'"
}

# Configure GitHub integration
configure_github() {
  echo "Would you like to configure GitHub integration? (y/n)"
  read -r setup_github
  
  if [[ "$setup_github" =~ ^[Yy]$ ]]; then
    echo "Please enter your GitHub username:"
    read -r github_username
    
    # Save to config file
    "$INSTALL_DIR/seatbelts.sh" --configure
    
    echo "GitHub integration configured."
  else
    echo "GitHub integration can be configured later using 'seatbelts --configure'"
  fi
}

# Main installation process
main() {
  install_dependencies
  setup_repository
  install_bats
  setup_config
  create_symlink
  setup_cron
  configure_github
  
  echo ""
  echo "==============================================="
  echo "🎉 Installation Complete!"
  echo "==============================================="
  echo ""
  echo "Seatbelts has been installed to $INSTALL_DIR"
  echo ""
  echo "You can now run Seatbelts with the following commands:"
  echo "  seatbelts        # Run security audit and push results"
  echo "  seatbelts --run  # Run security audit only"
  echo "  seatbelts --push # Push latest results to GitHub"
  echo ""
  echo "Security checks will run daily at 9:00 AM"
  echo "Results will be pushed to GitHub weekly on Monday at 10:00 AM"
  echo ""
  echo "For help, run: seatbelts --help"
  echo ""
  echo "Visit https://startr.sh/Seatbelts for documentation"
}

# Run installation
main