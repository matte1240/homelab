#!/bin/bash

# ================================
# HOMELAB MANAGEMENT SCRIPT
# ================================
# Version: 1.0
# Author: Your Name
# Description: Complete homelab management tool

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
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MAIN_COMPOSE_DIR="${SCRIPT_DIR}/base-services"
readonly COMPOSE_FILE="${MAIN_COMPOSE_DIR}/compose.yml"
readonly ENV_FILE="${SCRIPT_DIR}/.env"
readonly IMMICH_SETUP_SCRIPT="${SCRIPT_DIR}/immich/setup.sh"

# ================================
# UTILITY FUNCTIONS
# ================================

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker is installed but not running!"
        log_info "Please start Docker service and try again."
        exit 1
    fi
    
    return 0
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker &> /dev/null; then
        return 1
    fi
    
    # Check for docker compose (new) or docker-compose (legacy)
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        return 1
    fi
    
    return 0
}

# Install Docker on Ubuntu/Debian
install_docker_ubuntu() {
    log_info "Installing Docker on Ubuntu/Debian..."
    
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker installed successfully!"
    log_warning "Please log out and log back in for group changes to take effect."
    log_info "Alternatively, run: newgrp docker"
}

# Install Docker on CentOS/RHEL/Fedora
install_docker_redhat() {
    log_info "Installing Docker on CentOS/RHEL/Fedora..."
    
    # Remove old versions
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    
    # Install yum-utils
    sudo yum install -y yum-utils
    
    # Add Docker repository
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker installed successfully!"
    log_warning "Please log out and log back in for group changes to take effect."
}

# Install Docker on macOS
install_docker_macos() {
    log_info "Installing Docker on macOS..."
    
    if command -v brew &> /dev/null; then
        log_info "Using Homebrew to install Docker Desktop..."
        brew install --cask docker
        log_success "Docker Desktop installed via Homebrew!"
        log_info "Please start Docker Desktop from Applications folder."
    else
        log_warning "Homebrew not found. Please install Docker Desktop manually:"
        log_info "1. Go to https://www.docker.com/products/docker-desktop"
        log_info "2. Download Docker Desktop for Mac"
        log_info "3. Install and start Docker Desktop"
        exit 1
    fi
}

# Auto-detect OS and install Docker
install_docker() {
    log_header "DOCKER INSTALLATION"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if [[ -f /etc/debian_version ]]; then
            # Debian/Ubuntu
            install_docker_ubuntu
        elif [[ -f /etc/redhat-release ]]; then
            # CentOS/RHEL/Fedora
            install_docker_redhat
        else
            log_error "Unsupported Linux distribution!"
            log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        install_docker_macos
    else
        log_error "Unsupported operating system: $OSTYPE"
        log_info "Please install Docker manually: https://docs.docker.com/get-docker/"
        exit 1
    fi
}

# Check Docker installation and offer to install if missing
ensure_docker() {
    if ! check_docker; then
        log_warning "Docker is not installed or not running!"
        
        read -p "Would you like to install Docker automatically? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_docker
            
            # Check again after installation
            log_info "Checking Docker installation..."
            sleep 2
            
            if check_docker; then
                log_success "Docker is now installed and running!"
            else
                log_error "Docker installation failed or Docker is not running."
                log_info "Please start Docker manually and try again."
                exit 1
            fi
        else
            log_error "Docker is required to run this homelab."
            log_info "Please install Docker manually: https://docs.docker.com/get-docker/"
            exit 1
        fi
    fi
    
    if ! check_docker_compose; then
        log_error "Docker Compose is not available!"
        log_info "Docker Compose should be included with Docker. Please reinstall Docker."
        exit 1
    fi
    
    log_success "Docker and Docker Compose are ready!"
}

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
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed!"
        exit 1
    fi
    
    log_success "All requirements met!"
}

check_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_warning ".env file not found!"
        log_info "Creating .env from .env.example..."
        
        if [[ -f "${SCRIPT_DIR}/.env.example" ]]; then
            cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE"
            log_warning "Please edit .env file with your configuration before proceeding!"
            log_info "Required variables: CLOUDFLARE_API_TOKEN, DOMAINS, PIHOLE_WEBPASSWORD, PIHOLE_SERVERIP"
            return 1
        else
            log_error ".env.example not found!"
            return 1
        fi
    fi
    return 0
}

check_immich_setup() {
    local immich_lib_dir="${SCRIPT_DIR}/base-services/immich"
    if [[ ! -f "${immich_lib_dir}/.keep" ]]; then
        log_info "Setting up Immich for first time..."
        mkdir -p "$immich_lib_dir"
        touch "${immich_lib_dir}/.keep"
        
        # Generate JWT secret if not provided
        if [[ -z "${IMMICH_JWT_SECRET}" ]] || [[ "${IMMICH_JWT_SECRET}" == "your_jwt_secret_here_min_32_chars" ]]; then
            log_warning "Generating random JWT secret for Immich..."
            local jwt_secret
            jwt_secret=$(openssl rand -base64 32)
            
            # Update .env file if it exists
            if [[ -f "$ENV_FILE" ]]; then
                if grep -q "IMMICH_JWT_SECRET=" "$ENV_FILE"; then
                    sed -i "s/IMMICH_JWT_SECRET=.*/IMMICH_JWT_SECRET=${jwt_secret}/" "$ENV_FILE"
                else
                    echo "IMMICH_JWT_SECRET=${jwt_secret}" >> "$ENV_FILE"
                fi
                log_success "JWT secret updated in .env file"
            fi
        fi
    fi
}

# ================================
# INTERACTIVE SETUP
# ================================

interactive_setup() {
    log_header "INTERACTIVE HOMELAB SETUP"
    
    if [[ -f "$ENV_FILE" ]]; then
        log_warning ".env file already exists!"
        read -p "Do you want to overwrite it? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled. Existing .env file preserved."
            return 0
        fi
    fi
    
    log_info "This wizard will help you configure your homelab environment."
    echo
    
    # Copy template
    if [[ ! -f "${SCRIPT_DIR}/.env.example" ]]; then
        log_error ".env.example not found!"
        exit 1
    fi
    
    cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE"
    
    # General Configuration
    log_info "${YELLOW}General Configuration${NC}"
    read -p "Enter your timezone (default: Europe/Rome): " -r tz
    tz=${tz:-Europe/Rome}
    sed -i "s|TZ=.*|TZ=$tz|" "$ENV_FILE"
    
    # Cloudflare Configuration
    echo
    log_info "${YELLOW}Cloudflare DDNS Configuration${NC}"
    log_info "Get your API token from: https://dash.cloudflare.com/profile/api-tokens"
    read -p "Enter Cloudflare API Token: " -r cf_token
    read -p "Enter your domain (e.g., example.com): " -r domain
    
    sed -i "s|CLOUDFLARE_API_TOKEN=.*|CLOUDFLARE_API_TOKEN=$cf_token|" "$ENV_FILE"
    sed -i "s|DOMAINS=.*|DOMAINS=$domain|" "$ENV_FILE"
    
    # Pi-hole Configuration
    echo
    log_info "${YELLOW}Pi-hole Configuration${NC}"
    read -p "Enter Pi-hole web admin password: " -s pihole_pass
    echo
    read -p "Enter Pi-hole server IP (your homelab IP, e.g., 192.168.1.100): " -r pihole_ip
    
    sed -i "s|PIHOLE_WEBPASSWORD=.*|PIHOLE_WEBPASSWORD=$pihole_pass|" "$ENV_FILE"
    sed -i "s|PIHOLE_SERVERIP=.*|PIHOLE_SERVERIP=$pihole_ip|" "$ENV_FILE"
    
    # Immich Configuration
    echo
    log_info "${YELLOW}Immich Photo Server Configuration${NC}"
    read -p "Enter Immich database password: " -s immich_db_pass
    echo
    
    # Generate JWT secret (minimum 32 characters)
    immich_jwt=$(openssl rand -hex 32)
    
    sed -i "s|IMMICH_DB_PASSWORD=.*|IMMICH_DB_PASSWORD=$immich_db_pass|" "$ENV_FILE"
    sed -i "s|IMMICH_JWT_SECRET=.*|IMMICH_JWT_SECRET=$immich_jwt|" "$ENV_FILE"
    
    # Vaultwarden Configuration
    echo
    log_info "${YELLOW}Vaultwarden Password Manager Configuration${NC}"
    # Generate admin token
    vault_token=$(openssl rand -hex 32)
    sed -i "s|VAULTWARDEN_ADMIN_TOKEN=.*|VAULTWARDEN_ADMIN_TOKEN=$vault_token|" "$ENV_FILE"
    log_info "Generated Vaultwarden admin token: $vault_token"
    log_warning "Save this token - you'll need it to access the admin panel!"
    
    # CrowdSec Configuration
    echo
    log_info "${YELLOW}CrowdSec Security Configuration${NC}"
    # Generate bouncer key
    bouncer_key=$(openssl rand -hex 32)
    sed -i "s|CROWDSEC_BOUNCER_KEY=.*|CROWDSEC_BOUNCER_KEY=$bouncer_key|" "$ENV_FILE"
    
    # Optional SMTP Configuration
    echo
    read -p "Do you want to configure SMTP for email notifications? (y/N): " -r setup_smtp
    if [[ $setup_smtp =~ ^[Yy]$ ]]; then
        log_info "${YELLOW}SMTP Configuration${NC}"
        read -p "SMTP hostname (e.g., smtp.gmail.com): " -r smtp_host
        read -p "SMTP port (default: 587): " -r smtp_port
        smtp_port=${smtp_port:-587}
        read -p "SMTP username/email: " -r smtp_user
        read -p "SMTP password/app password: " -s smtp_pass
        echo
        
        sed -i "s|# SMTP_HOSTNAME=.*|SMTP_HOSTNAME=$smtp_host|" "$ENV_FILE"
        sed -i "s|# SMTP_PORT=.*|SMTP_PORT=$smtp_port|" "$ENV_FILE"
        sed -i "s|# SMTP_USERNAME=.*|SMTP_USERNAME=$smtp_user|" "$ENV_FILE"
        sed -i "s|# SMTP_PASSWORD=.*|SMTP_PASSWORD=$smtp_pass|" "$ENV_FILE"
    fi
    
    echo
    log_success "Configuration complete! .env file created successfully."
    log_info "You can now start your homelab with: ${GREEN}./manage.sh start${NC}"
    echo
    log_info "Generated credentials:"
    echo "  • Vaultwarden Admin Token: $vault_token"
    echo "  • Pi-hole Admin URL: http://pihole.home/admin"
    echo "  • Traefik Dashboard: http://traefik.home"
    echo
    log_warning "Keep these credentials secure!"
}

# ================================
# ENVIRONMENT & REQUIREMENTS
# ================================

start_all() {
    log_header "STARTING ALL SERVICES"
    
    check_immich_setup
    
    log_info "Starting all services..."
    cd "$MAIN_COMPOSE_DIR"
    docker-compose --env-file "$ENV_FILE" up -d
    
    log_success "All services started!"
    show_status
}

stop_all() {
    log_header "STOPPING ALL SERVICES"
    
    log_info "Stopping all services..."
    cd "$MAIN_COMPOSE_DIR"
    docker-compose down
    
    log_success "All services stopped!"
}

restart_all() {
    log_header "RESTARTING ALL SERVICES"
    stop_all
    sleep 2
    start_all
}

start_service() {
    local service="$1"
    log_info "Starting $service..."
    
    cd "$MAIN_COMPOSE_DIR"
    docker-compose --env-file "$ENV_FILE" up -d "$service"
    log_success "$service started successfully!"
}

stop_service() {
    local service="$1"
    log_info "Stopping $service..."
    
    cd "$MAIN_COMPOSE_DIR"
    docker-compose stop "$service"
    log_success "$service stopped successfully!"
}

restart_service() {
    local service="$1"
    stop_service "$service"
    start_service "$service"
}

# ================================
# MONITORING & STATUS
# ================================

show_status() {
    log_header "SERVICE STATUS"
    
    printf "%-25s %-15s %-10s\n" "SERVICE" "STATUS" "HEALTH"
    printf "%-25s %-15s %-10s\n" "-------" "------" "------"
    
    cd "$MAIN_COMPOSE_DIR"
    
    # List of expected services - using hardcoded list since include-based compose.yml doesn't work with config --services
    local services="traefik portainer heimdall uptime-kuma pihole vaultwarden crowdsec homer immich nginx watchtower cloudflare"
    
    for service in $services; do
        # Try to find container by service name pattern
        local container_name
        container_name=$(docker ps -a --format "{{.Names}}" | grep -E "^(homelab[_-])?${service}[_-]?[0-9]*$|^${service}$|${service}" | head -1)
        
        if [[ -n "$container_name" ]]; then
            local status
            local health
            status=$(docker inspect -f '{{.State.Status}}' "$container_name" 2>/dev/null || echo "unknown")
            health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-check{{end}}' "$container_name" 2>/dev/null || echo "unknown")
            
            case "$status" in
                "running")
                    if [[ "$health" == "healthy" ]]; then
                        printf "%-25s ${GREEN}%-15s${NC} ${GREEN}%-10s${NC}\n" "$service" "RUNNING" "$health"
                    elif [[ "$health" == "unhealthy" ]]; then
                        printf "%-25s ${GREEN}%-15s${NC} ${RED}%-10s${NC}\n" "$service" "RUNNING" "$health"
                    else
                        printf "%-25s ${GREEN}%-15s${NC} ${YELLOW}%-10s${NC}\n" "$service" "RUNNING" "$health"
                    fi
                    ;;
                "exited")
                    printf "%-25s ${RED}%-15s${NC} ${RED}%-10s${NC}\n" "$service" "STOPPED" "n/a"
                    ;;
                *)
                    printf "%-25s ${YELLOW}%-15s${NC} ${YELLOW}%-10s${NC}\n" "$service" "$status" "$health"
                    ;;
            esac
        else
            printf "%-25s ${RED}%-15s${NC} ${RED}%-10s${NC}\n" "$service" "NOT FOUND" "n/a"
        fi
    done
    
    echo
    log_info "Access URLs:"
    echo "  🔀  Traefik:        http://traefik.home"
    echo "  🎛️  Portainer:      http://portainer.home"
    echo "  🎯  Heimdall:       http://heimdall.home"
    echo "  ⏱️  Uptime Kuma:    http://uptime-kuma.home"
    echo "  🛡️  Pi-hole:        http://pihole.home"
    echo "  🔐  Vaultwarden:    http://vault.home"
    echo "  🏠  Homer:          http://homer.home"
    echo "  📸  Immich:         http://immich.home"
    echo "  �  Nginx PM:       http://nginx.home"
    echo
    log_info "API Endpoints:"
    echo "  🚔  CrowdSec API:   http://crowdsec.home (API only, no web UI)"
}

show_logs() {
    local service="$1"
    local lines="${2:-50}"
    
    log_info "Showing last $lines lines for $service..."
    cd "$MAIN_COMPOSE_DIR"
    docker compose logs --tail="$lines" -f "$service"
}

# ================================
# MAINTENANCE
# ================================

update_all() {
    log_header "UPDATING ALL SERVICES"
    
    log_info "Pulling latest images..."
    cd "$MAIN_COMPOSE_DIR"
    docker-compose pull
    
    log_info "Recreating services with new images..."
    docker-compose --env-file "$ENV_FILE" up -d
    
    log_success "All services updated!"
    show_status
}

backup() {
    local backup_dir="${SCRIPT_DIR}/backups/$(date +%Y%m%d_%H%M%S)"
    
    log_header "CREATING BACKUP"
    log_info "Backup directory: $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Backup configurations
    log_info "Backing up configurations..."
    cp -r "${SCRIPT_DIR}/base-services" "$backup_dir/"
    cp "$ENV_FILE" "$backup_dir/" 2>/dev/null || true
    
    # Backup Docker volumes
    log_info "Backing up Docker volumes..."
    cd "$MAIN_COMPOSE_DIR"
    
    # Backup Portainer data
    docker run --rm -v "$(pwd)":/backup -v base-services_portainer_data:/data alpine tar czf /backup/"$backup_dir"/portainer_data.tar.gz -C /data . 2>/dev/null || true
    
    # Backup Immich PostgreSQL
    docker-compose exec -T immich-postgres pg_dump -U postgres immich > "$backup_dir/immich_database.sql" 2>/dev/null || true
    
    # Backup Pi-hole config
    docker run --rm -v "$(pwd)":/backup -v "$(pwd)"/pihole:/data alpine tar czf /backup/"$backup_dir"/pihole_config.tar.gz -C /data . 2>/dev/null || true
    
    log_success "Backup created: $backup_dir"
}

cleanup() {
    log_header "CLEANING UP DOCKER SYSTEM"
    
    log_info "Removing unused containers..."
    docker container prune -f
    
    log_info "Removing unused images..."
    docker image prune -a -f
    
    log_info "Removing unused volumes..."
    docker volume prune -f
    
    log_info "Removing unused networks..."
    docker network prune -f
    
    log_success "Cleanup completed!"
}

# ================================
# HELP & USAGE
# ================================

show_help() {
    echo
    echo -e "${PURPLE}🏠 Homelab Management Script${NC}"
    echo
    echo -e "${YELLOW}📋 USAGE:${NC}"
    echo "    ./manage.sh [COMMAND] [OPTIONS]"
    echo
    echo -e "${YELLOW}⚡ COMMANDS:${NC}"
    printf "    ${GREEN}%-20s${NC} %s\n" "setup" "🔧 Interactive configuration wizard"
    printf "    ${GREEN}%-20s${NC} %s\n" "start [service]" "▶️  Start service or all services"
    printf "    ${GREEN}%-20s${NC} %s\n" "stop [service]" "⏹️  Stop service or all services"
    printf "    ${GREEN}%-20s${NC} %s\n" "restart [service]" "🔄 Restart service or all services"
    printf "    ${GREEN}%-20s${NC} %s\n" "status" "📊 Show status of all services"
    printf "    ${GREEN}%-20s${NC} %s\n" "logs [service]" "📝 Show logs for service"
    printf "    ${GREEN}%-20s${NC} %s\n" "update" "⬆️  Update all services"
    printf "    ${GREEN}%-20s${NC} %s\n" "cleanup" "🧹 Clean unused Docker resources"
    printf "    ${GREEN}%-20s${NC} %s\n" "backup" "💾 Create backup of configurations"
    printf "    ${GREEN}%-20s${NC} %s\n" "help" "❓ Show this help message"
    echo
    echo -e "${YELLOW}🐳 SERVICES:${NC}"
    printf "    • %-18s %s\n" "traefik" "🔀 Reverse proxy"
    printf "    • %-18s %s\n" "portainer" "🎛️  Container management"
    printf "    • %-18s %s\n" "heimdall" "🎯 Dashboard"
    printf "    • %-18s %s\n" "uptime-kuma" "⏱️  Uptime monitoring"
    printf "    • %-18s %s\n" "watchtower" "🔄 Auto updates"
    printf "    • %-18s %s\n" "pihole" "🛡️  DNS & Ad blocking"
    printf "    • %-18s %s\n" "vaultwarden" "🔐 Password manager"
    printf "    • %-18s %s\n" "crowdsec" "🚔 Security system"
    printf "    • %-18s %s\n" "homer" "🏠 Custom dashboard"
    printf "    • %-18s %s\n" "immich" "📸 Photo backup server"
    printf "    • %-18s %s\n" "nginx" "🔧 Nginx proxy manager"
    printf "    • %-18s %s\n" "cloudflare" "☁️  Dynamic DNS"
    echo
    echo -e "${YELLOW}💡 EXAMPLES:${NC}"
    printf "    ${CYAN}%-35s${NC} %s\n" "./manage.sh setup" "# Run interactive setup wizard"
    printf "    ${CYAN}%-35s${NC} %s\n" "./manage.sh start" "# Start all services"
    printf "    ${CYAN}%-35s${NC} %s\n" "./manage.sh start traefik" "# Start only Traefik"
    printf "    ${CYAN}%-35s${NC} %s\n" "./manage.sh logs immich 100" "# Show last 100 lines of Immich logs"
    printf "    ${CYAN}%-35s${NC} %s\n" "./manage.sh status" "# Show status of all services"
    echo
    echo -e "${YELLOW}📋 REQUIREMENTS:${NC}"
    echo "    • Docker and Docker Compose installed"
    echo "    • .env file configured (run setup command)"
    echo
}

# ================================
# MAIN FUNCTION
# ================================

main() {
    # Ensure Docker is installed and running
    ensure_docker
    
    case "${1:-}" in
        "setup")
            interactive_setup
            ;;
        "start")
            check_requirements
            if ! check_env_file; then
                exit 1
            fi
            
            if [[ -n "${2:-}" ]]; then
                start_service "$2"
            else
                start_all
            fi
            ;;
        "stop")
            if [[ -n "${2:-}" ]]; then
                stop_service "$2"
            else
                stop_all
            fi
            ;;
        "restart")
            check_requirements
            if ! check_env_file; then
                exit 1
            fi
            
            if [[ -n "${2:-}" ]]; then
                restart_service "$2"
            else
                restart_all
            fi
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "${2:-traefik}" "${3:-50}"
            ;;
        "update")
            check_requirements
            update_all
            ;;
        "cleanup")
            cleanup
            ;;
        "backup")
            backup
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: ${1:-}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
