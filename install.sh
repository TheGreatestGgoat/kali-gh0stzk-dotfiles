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
# Save the original directory to return to it later
ORIGINAL_DIR=$(pwd)

# Define text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
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

print_question() {
    echo -e "${CYAN}[?]${NC} $1"
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

# Function to ask yes/no questions
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt+=" [Y/n] "
    else
        prompt+=" [y/N] "
    fi
    
    local answer
    read -p "$prompt" answer
    
    # Default if empty
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    
    # Convert to lowercase
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$answer" =~ ^(yes|y)$ ]]; then
        return 0  # True in bash
    else
        return 1  # False in bash
    fi
}

# Function to run a script from the kali-scripts directory
run_script() {
    script_name="$1"
    script_path="$SCRIPTS_DIR/$script_name"
    
    # Change to the scripts directory to avoid relative path issues
    cd "$SCRIPTS_DIR" || { 
        print_error "Could not change to directory: $SCRIPTS_DIR"
        exit 1
    }
    
    # Run the script by its name (not full path)
    if ./"$script_name"; then
        # Change back to original directory
        cd "$ORIGINAL_DIR" || {
            print_error "Could not change back to original directory: $ORIGINAL_DIR"
            exit 1
        }
        return 0
    else
        # Change back to original directory even if the script fails
        cd "$ORIGINAL_DIR" || {
            print_error "Could not change back to original directory: $ORIGINAL_DIR"
            exit 1
        }
        return 1
    fi
}

# Check system configuration
check_system() {
    # Check for existing installations
    BSPWM_INSTALLED=0
    RUST_INSTALLED=0
    NEOVIM_INSTALLED=0
    
    if command -v bspwm >/dev/null 2>&1; then
        BSPWM_INSTALLED=1
        print_warning "BSPWM is already installed on your system."
    fi
    
    if command -v rustc >/dev/null 2>&1; then
        RUST_INSTALLED=1
        print_warning "Rust is already installed on your system."
    fi
    
    if command -v nvim >/dev/null 2>&1; then
        NEOVIM_INSTALLED=1
        print_warning "Neovim is already installed on your system."
    fi
    
    if [ -d "$HOME/.config/bspwm/rices" ]; then
        print_warning "Dotfiles appear to be already installed in ~/.config/bspwm/"
    fi
    
    # If any of the components are already installed, ask user if they want to continue
    if [ $BSPWM_INSTALLED -eq 1 ] || [ $RUST_INSTALLED -eq 1 ] || [ $NEOVIM_INSTALLED -eq 1 ]; then
        echo ""
        print_warning "Some components are already installed on your system."
        print_warning "Running this installation may overwrite existing configurations or fail."
        echo ""
        
        if ! ask_yes_no "Do you want to continue with the installation?"; then
            print_status "Installation aborted by user."
            exit 0
        fi
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

# Check the system and warn about existing installations
check_system

# Execute each script in order, with options to skip steps
print_status "Starting installation process..."

# Step 1: Dependencies
print_question "Do you want to install dependencies? (Skip if already installed)"
if ask_yes_no "Install dependencies?"; then
    print_status "Step 1/4: Installing dependencies..."
    if run_script "InstallDependencies"; then
        print_success "Dependencies installation completed!"
    else
        print_error "Dependencies installation failed!"
        if ! ask_yes_no "Continue with the next steps anyway?"; then
            print_status "Installation aborted by user."
            exit 1
        fi
    fi
else
    print_status "Skipping dependencies installation..."
fi

# Step 2: Eww
print_question "Do you want to install Eww? (Skip if already installed)"
if ask_yes_no "Install Eww?"; then
    print_status "Step 2/4: Installing Eww..."
    if run_script "InstallEww"; then
        print_success "Eww installation completed!"
    else
        print_error "Eww installation failed!"
        if ! ask_yes_no "Continue with the next steps anyway?"; then
            print_status "Installation aborted by user."
            exit 1
        fi
    fi
else
    print_status "Skipping Eww installation..."
fi

# Step 3: Dotfiles
print_question "Do you want to install dotfiles? (Skip if you just want to update existing dotfiles)"
if ask_yes_no "Install dotfiles?"; then
    print_status "Step 3/4: Installing dotfiles..."
    if run_script "InstallDotFiles"; then
        print_success "Dotfiles installation completed!"
    else
        print_error "Dotfiles installation failed!"
        if ! ask_yes_no "Continue with the next step anyway?"; then
            print_status "Installation aborted by user."
            exit 1
        fi
    fi
else
    print_status "Skipping dotfiles installation..."
fi

# Step 4: Post-installation
print_question "Do you want to run post-installation tasks?"
if ask_yes_no "Run post-installation tasks?"; then
    print_status "Step 4/4: Running post-installation tasks..."
    if run_script "PostInstallation"; then
        print_success "Post-installation tasks completed!"
    else
        print_error "Post-installation tasks failed!"
    fi
else
    print_status "Skipping post-installation tasks..."
fi

print_success "Installation process completed!"
echo ""
echo -e "${GREEN}If you installed or updated dotfiles, please reboot your system to apply all changes.${NC}"
echo -e "${BLUE}After rebooting, you can select your rice theme using the RiceSelector command.${NC}" 