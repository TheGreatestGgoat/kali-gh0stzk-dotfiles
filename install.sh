#!/usr/bin/env bash
#
# ██╗  ██╗██╗  ██╗██╗  ██╗███████╗███╗   ██╗ ██████╗ ███████╗
# ╚██╗██╔╝╚██╗██╔╝██║  ██║██╔════╝████╗  ██║██╔═══██╗██╔════╝
#  ╚███╔╝  ╚███╔╝ ███████║█████╗  ██╔██╗ ██║██║   ██║███████╗
#  ██╔██╗  ██╔██╗ ╚════██║██╔══╝  ██║╚██╗██║██║   ██║╚════██║
# ██╔╝ ██╗██╔╝ ██╗     ██║███████╗██║ ╚████║╚██████╔╝███████║
# ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
#
# Kali Linux Installation Wrapper Script for gh0stzk-dotfiles
# Originally by gh0stzk (https://github.com/gh0stzk/dotfiles)
# Kali Linux adaptation based on ChrisMethsillo's work
# Modified by xxxenos
#

# Define the scripts directory
SCRIPTS_DIR="./kali-scripts"

# Define text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print messages with colors
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

# Function to check if a script exists and is executable
check_script() {
    if [ ! -f "$1" ]; then
        print_error "Script $1 not found!"
        exit 1
    fi
    
    if [ ! -x "$1" ]; then
        print_warning "Script $1 is not executable. Making it executable..."
        chmod +x "$1"
    fi
}

# Check if kali-scripts directory exists
if [ ! -d "$SCRIPTS_DIR" ]; then
    print_error "Directory '$SCRIPTS_DIR' not found! Please make sure you're running this script from the correct location."
    exit 1
fi

# Check for all scripts before starting
print_status "Checking if all required scripts exist..."
check_script "${SCRIPTS_DIR}/InstallDependencies"
check_script "${SCRIPTS_DIR}/InstallEww"
check_script "${SCRIPTS_DIR}/InstallDotFiles"
check_script "${SCRIPTS_DIR}/PostInstallation"
print_success "All scripts found!"

# Execute each script in order
print_status "Starting installation process..."

print_status "Step 1/4: Installing dependencies..."
if "${SCRIPTS_DIR}/InstallDependencies"; then
    print_success "Dependencies installation completed!"
else
    print_error "Dependencies installation failed! Exiting."
    exit 1
fi

print_status "Step 2/4: Installing Eww..."
if "${SCRIPTS_DIR}/InstallEww"; then
    print_success "Eww installation completed!"
else
    print_error "Eww installation failed! Exiting."
    exit 1
fi

print_status "Step 3/4: Installing dotfiles..."
if "${SCRIPTS_DIR}/InstallDotFiles"; then
    print_success "Dotfiles installation completed!"
else
    print_error "Dotfiles installation failed! Exiting."
    exit 1
fi

print_status "Step 4/4: Running post-installation tasks..."
if "${SCRIPTS_DIR}/PostInstallation"; then
    print_success "Post-installation tasks completed!"
else
    print_error "Post-installation tasks failed! Exiting."
    exit 1
fi

print_success "Installation complete! Please reboot your system to apply all changes."
echo ""
echo -e "${GREEN}After rebooting, you can select your rice theme using the RiceSelector command.${NC}"
echo -e "${BLUE}Enjoy your new desktop environment!${NC}" 