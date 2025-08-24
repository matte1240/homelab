#!/bin/bash
# =================================
# HOMELAB ONE-LINE INSTALLER
# =================================
# Quick install: curl -fsSL https://raw.githubusercontent.com/matte1240/homelab/main/install.sh | bash
# Or with wget: wget -qO- https://raw.githubusercontent.com/matte1240/homelab/main/install.sh | bash

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
readonly REPO_URL="https://github.com/matte1240/homelab.git"
readonly INSTALL_DIR="$HOME/homelab"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root!"
        log_info "Run as a regular user with sudo privileges instead."
        exit 1
    fi
}

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        log_warning "Git is not installed. Installing git..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y git
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y git || sudo dnf install -y git
        else
            log_error "Please install git manually and run this script again."
            exit 1
        fi
    fi
    log_success "Git is available!"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_warning "Docker is not installed."
        log_info "The homelab setup script will help you install Docker."
        return 1
    fi
    
    if ! docker version &> /dev/null; then
        log_warning "Docker is installed but not running."
        log_info "The homelab setup script will help you start Docker."
        return 1
    fi
    
    log_success "Docker is ready!"
    return 0
}

# Clone or update repository
setup_repository() {
    log_header "SETTING UP HOMELAB REPOSITORY"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        log_warning "Homelab directory already exists at $INSTALL_DIR"
        read -p "Do you want to update it? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Updating existing repository..."
            cd "$INSTALL_DIR"
            git pull origin main
        else
            log_info "Using existing repository..."
            cd "$INSTALL_DIR"
        fi
    else
        log_info "Cloning homelab repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
    
    # Make manage.sh executable
    chmod +x manage.sh
    log_success "Repository ready at $INSTALL_DIR"
}

# Show next steps
show_next_steps() {
    log_header "INSTALLATION COMPLETE!"
    
    echo -e "${GREEN}🎉 Homelab repository has been set up successfully!${NC}"
    echo
    echo -e "${YELLOW}📍 Location:${NC} $INSTALL_DIR"
    echo
    echo -e "${YELLOW}🚀 Next Steps:${NC}"
    echo "1. Navigate to the homelab directory:"
    echo -e "   ${CYAN}cd $INSTALL_DIR${NC}"
    echo
    echo "2. Run the interactive setup wizard:"
    echo -e "   ${CYAN}./manage.sh setup${NC}"
    echo
    echo "3. Start your homelab:"
    echo -e "   ${CYAN}./manage.sh start${NC}"
    echo
    echo "4. Check status of all services:"
    echo -e "   ${CYAN}./manage.sh status${NC}"
    echo
    echo -e "${YELLOW}📚 Documentation:${NC}"
    echo "• README.md - Overview and service descriptions"
    echo "• SETUP.md - Detailed setup instructions"
    echo "• TROUBLESHOOTING.md - Common issues and solutions"
    echo
    echo -e "${YELLOW}💡 Quick Help:${NC}"
    echo -e "   ${CYAN}./manage.sh help${NC}"
    echo
    
    if ! check_docker; then
        echo -e "${YELLOW}⚠️  Note:${NC} Docker is not installed or running."
        echo "The setup wizard will help you install and configure Docker."
        echo
    fi
    
    echo -e "${GREEN}🏠 Welcome to your new homelab!${NC}"
}

# Main installation function
main() {
    log_header "🏠 HOMELAB ONE-LINE INSTALLER"
    
    echo -e "${CYAN}This script will install the Homelab management system${NC}"
    echo -e "${CYAN}Repository: ${REPO_URL}${NC}"
    echo
    
    # Perform checks
    check_not_root
    check_git
    
    # Setup repository
    setup_repository
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
