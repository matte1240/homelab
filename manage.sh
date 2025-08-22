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
readonly SERVICES=("base-services" "dyndns" "immich" "nginx")
readonly ENV_FILE="${SCRIPT_DIR}/.env"

# ================================
# UTILITY FUNCTIONS
# ================================

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

# ================================
# SERVICE MANAGEMENT
# ================================

start_service() {
    local service="$1"
    log_info "Starting $service..."
    
    if [[ -f "${SCRIPT_DIR}/${service}/compose.yml" ]]; then
        cd "${SCRIPT_DIR}/${service}"
        docker-compose --env-file "$ENV_FILE" up -d
        log_success "$service started successfully!"
    else
        log_error "Service $service not found!"
        return 1
    fi
}

stop_service() {
    local service="$1"
    log_info "Stopping $service..."
    
    if [[ -f "${SCRIPT_DIR}/${service}/compose.yml" ]]; then
        cd "${SCRIPT_DIR}/${service}"
        docker-compose down
        log_success "$service stopped successfully!"
    else
        log_error "Service $service not found!"
        return 1
    fi
}

restart_service() {
    local service="$1"
    stop_service "$service"
    start_service "$service"
}

start_all() {
    log_header "STARTING ALL SERVICES"
    
    for service in "${SERVICES[@]}"; do
        if [[ "$service" == "immich" ]]; then
            # Special handling for Immich
            log_info "Setting up Immich..."
            cd "${SCRIPT_DIR}/immich"
            if [[ -x "./setup.sh" ]]; then
                ./setup.sh
            fi
        fi
        start_service "$service"
    done
    
    log_success "All services started!"
    show_status
}

stop_all() {
    log_header "STOPPING ALL SERVICES"
    
    for service in "${SERVICES[@]}"; do
        stop_service "$service"
    done
    
    log_success "All services stopped!"
}

# ================================
# MONITORING & STATUS
# ================================

show_status() {
    log_header "SERVICE STATUS"
    
    printf "%-20s %-15s %-10s\n" "SERVICE" "STATUS" "CONTAINERS"
    printf "%-20s %-15s %-10s\n" "-------" "------" "----------"
    
    for service in "${SERVICES[@]}"; do
        if [[ -f "${SCRIPT_DIR}/${service}/compose.yml" ]]; then
            cd "${SCRIPT_DIR}/${service}"
            local container_count
            container_count=$(docker-compose ps -q | wc -l)
            local running_count
            running_count=$(docker-compose ps -q | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null | grep -c "running" || echo "0")
            
            if [[ "$running_count" -eq "$container_count" ]] && [[ "$container_count" -gt 0 ]]; then
                printf "%-20s ${GREEN}%-15s${NC} %-10s\n" "$service" "RUNNING" "$running_count/$container_count"
            elif [[ "$running_count" -gt 0 ]]; then
                printf "%-20s ${YELLOW}%-15s${NC} %-10s\n" "$service" "PARTIAL" "$running_count/$container_count"
            else
                printf "%-20s ${RED}%-15s${NC} %-10s\n" "$service" "STOPPED" "$running_count/$container_count"
            fi
        fi
    done
    
    echo
    log_info "Access URLs:"
    echo "  🎛️  Portainer:    http://portainer.local"
    echo "  🎯  Heimdall:     http://heimdall.local"
    echo "  ⏱️  Uptime Kuma:  http://uptime.local"
    echo "  🛡️  Pi-hole:      http://pihole.local"
    echo "  🔐  Vaultwarden:  http://vault.local"
    echo "  🏠  Homer:        http://home.local"
    echo "  📸  Immich:       http://localhost:2283"
    echo "  🌐  Traefik:      http://traefik.local"
}

show_logs() {
    local service="$1"
    local lines="${2:-50}"
    
    if [[ -f "${SCRIPT_DIR}/${service}/compose.yml" ]]; then
        log_info "Showing last $lines lines for $service..."
        cd "${SCRIPT_DIR}/${service}"
        docker-compose logs --tail="$lines" -f
    else
        log_error "Service $service not found!"
        return 1
    fi
}

# ================================
# MAINTENANCE
# ================================

update_all() {
    log_header "UPDATING ALL SERVICES"
    
    for service in "${SERVICES[@]}"; do
        log_info "Updating $service..."
        cd "${SCRIPT_DIR}/${service}"
        docker-compose pull
        docker-compose up -d
    done
    
    log_success "All services updated!"
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

backup() {
    local backup_dir="${SCRIPT_DIR}/backups/$(date +%Y%m%d_%H%M%S)"
    
    log_header "CREATING BACKUP"
    log_info "Backup directory: $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Backup configurations
    for service in "${SERVICES[@]}"; do
        if [[ -d "${SCRIPT_DIR}/${service}" ]]; then
            log_info "Backing up $service configuration..."
            cp -r "${SCRIPT_DIR}/${service}" "$backup_dir/"
        fi
    done
    
    # Backup Docker volumes
    log_info "Backing up Docker volumes..."
    docker run --rm -v "$(pwd)":/backup -v portainer_data:/data alpine tar czf /backup/"$backup_dir"/portainer_data.tar.gz -C /data .
    
    log_success "Backup created: $backup_dir"
}

# ================================
# HELP & USAGE
# ================================

show_help() {
    cat << EOF
${PURPLE}Homelab Management Script${NC}

${YELLOW}USAGE:${NC}
    ./manage.sh [COMMAND] [OPTIONS]

${YELLOW}COMMANDS:${NC}
    ${GREEN}start [service]${NC}     Start service or all services
    ${GREEN}stop [service]${NC}      Stop service or all services  
    ${GREEN}restart [service]${NC}   Restart service or all services
    ${GREEN}status${NC}              Show status of all services
    ${GREEN}logs [service] [lines]${NC} Show logs for service (default: 50 lines)
    ${GREEN}update${NC}              Update all services
    ${GREEN}cleanup${NC}             Clean unused Docker resources
    ${GREEN}backup${NC}              Create backup of configurations
    ${GREEN}help${NC}                Show this help message

${YELLOW}SERVICES:${NC}
    • base-services  (Traefik, Portainer, Heimdall, etc.)
    • dyndns         (Cloudflare DDNS)
    • immich         (Photo backup)
    • nginx          (Nginx Proxy Manager)

${YELLOW}EXAMPLES:${NC}
    ./manage.sh start              # Start all services
    ./manage.sh start base-services # Start only base services
    ./manage.sh logs immich 100    # Show last 100 lines of Immich logs
    ./manage.sh status             # Show status of all services

${YELLOW}REQUIREMENTS:${NC}
    • Docker and Docker Compose installed
    • .env file configured (copy from .env.example)

EOF
}

# ================================
# MAIN FUNCTION
# ================================

main() {
    case "${1:-}" in
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
                stop_all
                start_all
            fi
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "${2:-base-services}" "${3:-50}"
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
