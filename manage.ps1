# ================================
# HOMELAB MANAGEMENT SCRIPT - PowerShell Version
# ================================
# Version: 1.0
# Description: Complete homelab management tool for Windows

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1)]
    [string]$Service,
    
    [Parameter(Position=2)]
    [int]$Lines = 50
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MainComposeDir = Join-Path $ScriptDir "base-services"
$ComposeFile = Join-Path $MainComposeDir "compose.yml"
$EnvFile = Join-Path $ScriptDir ".env"

# Colors
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Purple = "Magenta"
$Cyan = "Cyan"

# ================================
# UTILITY FUNCTIONS
# ================================

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "================================" -ForegroundColor $Purple
    Write-Host $Message -ForegroundColor $Purple
    Write-Host "================================" -ForegroundColor $Purple
}

# ================================
# DOCKER INSTALLATION FUNCTIONS
# ================================

function Test-Docker {
    try {
        $null = Get-Command docker -ErrorAction Stop
        $dockerInfo = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $true
        } else {
            Write-Error "Docker is installed but not running!"
            Write-Info "Please start Docker Desktop and try again."
            exit 1
        }
    } catch {
        return $false
    }
}

function Test-DockerCompose {
    try {
        $null = Get-Command docker -ErrorAction Stop
        
        # Test docker compose (new syntax)
        $composeTest = docker compose version 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        
        # Test docker-compose (legacy)
        $null = Get-Command docker-compose -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Install-DockerDesktop {
    Write-Header "DOCKER INSTALLATION"
    Write-Info "Installing Docker Desktop for Windows..."
    
    # Check if Chocolatey is available
    try {
        $null = Get-Command choco -ErrorAction Stop
        Write-Info "Using Chocolatey to install Docker Desktop..."
        
        Start-Process -FilePath "choco" -ArgumentList "install", "docker-desktop", "-y" -Wait -Verb RunAs
        
        Write-Success "Docker Desktop installed via Chocolatey!"
        Write-Info "Please start Docker Desktop from Start Menu."
        
        return $true
    } catch {
        Write-Warning "Chocolatey not found. Using manual installation..."
    }
    
    # Check if winget is available (Windows 10 version 1809+)
    try {
        $null = Get-Command winget -ErrorAction Stop
        Write-Info "Using winget to install Docker Desktop..."
        
        winget install Docker.DockerDesktop
        
        Write-Success "Docker Desktop installed via winget!"
        Write-Info "Please start Docker Desktop from Start Menu."
        
        return $true
    } catch {
        Write-Warning "winget not found. Manual installation required."
    }
    
    # Manual download instructions
    Write-Warning "Automatic installation failed. Please install Docker Desktop manually:"
    Write-Info "1. Go to https://www.docker.com/products/docker-desktop"
    Write-Info "2. Download Docker Desktop for Windows"
    Write-Info "3. Run the installer as Administrator"
    Write-Info "4. Restart your computer if prompted"
    Write-Info "5. Start Docker Desktop and complete setup"
    
    $response = Read-Host "Press 'y' when Docker Desktop is installed and running, or 'n' to exit"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        return $true
    } else {
        return $false
    }
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Docker {
    if (-not (Test-Docker)) {
        Write-Warning "Docker is not installed or not running!"
        
        $response = Read-Host "Would you like to install Docker Desktop automatically? (y/n)"
        
        if ($response -eq 'y' -or $response -eq 'Y') {
            # Check if running as administrator for some installation methods
            if (-not (Test-AdminRights)) {
                Write-Warning "Some installation methods require administrator privileges."
                Write-Info "Consider running PowerShell as Administrator for better results."
            }
            
            $installResult = Install-DockerDesktop
            
            if ($installResult) {
                Write-Info "Waiting for Docker to start..."
                
                # Wait for Docker to start (max 2 minutes)
                $timeout = 120
                $elapsed = 0
                
                while ($elapsed -lt $timeout) {
                    Start-Sleep -Seconds 5
                    $elapsed += 5
                    
                    if (Test-Docker) {
                        Write-Success "Docker is now installed and running!"
                        break
                    }
                    
                    Write-Info "Still waiting for Docker to start... ($elapsed/$timeout seconds)"
                }
                
                if ($elapsed -ge $timeout) {
                    Write-Error "Docker installation completed but Docker is not running."
                    Write-Info "Please start Docker Desktop manually and try again."
                    exit 1
                }
            } else {
                Write-Error "Docker installation failed or was cancelled."
                Write-Info "Please install Docker Desktop manually: https://docs.docker.com/desktop/install/windows-install/"
                exit 1
            }
        } else {
            Write-Error "Docker is required to run this homelab."
            Write-Info "Please install Docker Desktop manually: https://docs.docker.com/desktop/install/windows-install/"
            exit 1
        }
    }
    
    if (-not (Test-DockerCompose)) {
        Write-Error "Docker Compose is not available!"
        Write-Info "Docker Compose should be included with Docker Desktop. Please reinstall Docker Desktop."
        exit 1
    }
    
    Write-Success "Docker and Docker Compose are ready!"
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "================================" -ForegroundColor $Purple
    Write-Host $Message -ForegroundColor $Purple
    Write-Host "================================" -ForegroundColor $Purple
}

function Test-Requirements {
    Write-Info "Checking requirements..."
    
    # Check Docker
    try {
        $null = docker --version
    } catch {
        Write-Error "Docker is not installed or not in PATH!"
        return $false
    }
    
    # Check Docker Compose
    try {
        $null = docker-compose --version
    } catch {
        try {
            $null = docker compose version
        } catch {
            Write-Error "Docker Compose is not installed!"
            return $false
        }
    }
    
    Write-Success "All requirements met!"
    return $true
}

function Test-EnvFile {
    if (-not (Test-Path $EnvFile)) {
        Write-Warning ".env file not found!"
        Write-Info "Creating .env from .env.example..."
        
        $ExampleFile = Join-Path $ScriptDir ".env.example"
        if (Test-Path $ExampleFile) {
            Copy-Item $ExampleFile $EnvFile
            Write-Warning "Please edit .env file with your configuration before proceeding!"
            Write-Info "Required variables: CLOUDFLARE_API_TOKEN, DOMAINS, PIHOLE_WEBPASSWORD, PIHOLE_SERVERIP"
            return $false
        } else {
            Write-Error ".env.example not found!"
            return $false
        }
    }
    return $true
}

# ================================
# SERVICE MANAGEMENT
# ================================

function Start-AllServices {
    Write-Header "STARTING ALL SERVICES"
    
    Test-ImmichSetup
    
    Write-Info "Starting all services..."
    Set-Location $MainComposeDir
    docker-compose --env-file $EnvFile up -d
    
    Write-Success "All services started!"
    Show-Status
}

function Stop-AllServices {
    Write-Header "STOPPING ALL SERVICES"
    
    Write-Info "Stopping all services..."
    Set-Location $MainComposeDir
    docker-compose down
    
    Write-Success "All services stopped!"
}

function Start-Service {
    param([string]$ServiceName)
    Write-Info "Starting $ServiceName..."
    
    Set-Location $MainComposeDir
    docker-compose --env-file $EnvFile up -d $ServiceName
    Write-Success "$ServiceName started successfully!"
}

function Stop-Service {
    param([string]$ServiceName)
    Write-Info "Stopping $ServiceName..."
    
    Set-Location $MainComposeDir
    docker-compose stop $ServiceName
    Write-Success "$ServiceName stopped successfully!"
}

function Test-ImmichSetup {
    $ImmichLibrary = Join-Path $ScriptDir "base-services\immich"
    $KeepFile = Join-Path $ImmichLibrary ".keep"
    
    if (-not (Test-Path $KeepFile)) {
        Write-Info "Setting up Immich for first time..."
        if (-not (Test-Path $ImmichLibrary)) {
            New-Item -ItemType Directory -Path $ImmichLibrary -Force | Out-Null
        }
        New-Item -ItemType File -Path $KeepFile -Force | Out-Null
        
        Write-Warning "Make sure to configure IMMICH_JWT_SECRET in your .env file!"
    }
}

# ================================
# STATUS AND MONITORING
# ================================

function Show-Status {
    Write-Header "SERVICE STATUS"
    
    Set-Location $MainComposeDir
    
    # Get services from compose file
    $Services = docker-compose config --services
    
    Write-Host ("{0,-25} {1,-15} {2,-10}" -f "SERVICE", "STATUS", "HEALTH") -ForegroundColor White
    Write-Host ("{0,-25} {1,-15} {2,-10}" -f "-------", "------", "------") -ForegroundColor White
    
    foreach ($ServiceName in $Services) {
        $ContainerId = docker-compose ps -q $ServiceName 2>$null
        
        if ($ContainerId) {
            $Status = docker inspect -f '{{.State.Status}}' $ContainerId 2>$null
            $Health = docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-check{{end}}' $ContainerId 2>$null
            
            $StatusColor = switch ($Status) {
                "running" { $Green }
                "exited" { $Red }
                default { $Yellow }
            }
            
            $HealthColor = switch ($Health) {
                "healthy" { $Green }
                "unhealthy" { $Red }
                default { $Yellow }
            }
            
            Write-Host ("{0,-25}" -f $ServiceName) -NoNewline
            Write-Host ("{0,-15}" -f $Status.ToUpper()) -ForegroundColor $StatusColor -NoNewline
            Write-Host ("{0,-10}" -f $Health) -ForegroundColor $HealthColor
        } else {
            Write-Host ("{0,-25}" -f $ServiceName) -NoNewline
            Write-Host ("{0,-15}" -f "NOT FOUND") -ForegroundColor $Red -NoNewline
            Write-Host ("{0,-10}" -f "n/a") -ForegroundColor $Red
        }
    }
    
    Write-Host
    Write-Info "Access URLs:"
    Write-Host "  🎛️  Portainer:      http://portainer.local"
    Write-Host "  🎯  Heimdall:       http://heimdall.local"
    Write-Host "  ⏱️  Uptime Kuma:    http://uptime.local"
    Write-Host "  🛡️  Pi-hole:        http://pihole.local"
    Write-Host "  🔐  Vaultwarden:    http://vault.local"
    Write-Host "  🏠  Homer:          http://home.local"
    Write-Host "  📸  Immich:         http://immich.local"
    Write-Host "  🌐  Traefik:        http://traefik.local"
    Write-Host "  🔧  Nginx PM:       http://nginx.local"
}

function Show-Logs {
    param([string]$ServiceName, [int]$LogLines)
    
    Write-Info "Showing last $LogLines lines for $ServiceName..."
    Set-Location $MainComposeDir
    docker-compose logs --tail=$LogLines -f $ServiceName
}

# ================================
# MAINTENANCE
# ================================

function Update-AllServices {
    Write-Header "UPDATING ALL SERVICES"
    
    Write-Info "Pulling latest images..."
    Set-Location $MainComposeDir
    docker-compose pull
    
    Write-Info "Recreating services with new images..."
    docker-compose --env-file $EnvFile up -d
    
    Write-Success "All services updated!"
    Show-Status
}

function Invoke-Cleanup {
    Write-Header "CLEANING UP DOCKER SYSTEM"
    
    Write-Info "Removing unused containers..."
    docker container prune -f
    
    Write-Info "Removing unused images..."
    docker image prune -a -f
    
    Write-Info "Removing unused volumes..."
    docker volume prune -f
    
    Write-Info "Removing unused networks..."
    docker network prune -f
    
    Write-Success "Cleanup completed!"
}

function New-Backup {
    $BackupDir = Join-Path $ScriptDir "backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    Write-Header "CREATING BACKUP"
    Write-Info "Backup directory: $BackupDir"
    
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    
    # Backup configurations
    Write-Info "Backing up configurations..."
    Copy-Item -Recurse (Join-Path $ScriptDir "base-services") $BackupDir
    Copy-Item -Recurse (Join-Path $ScriptDir "immich") $BackupDir
    if (Test-Path $EnvFile) {
        Copy-Item $EnvFile $BackupDir
    }
    
    Write-Success "Backup created: $BackupDir"
}

# ================================
# HELP
# ================================

function Show-Help {
    Write-Host "Homelab Management Script - PowerShell Version" -ForegroundColor $Purple
    Write-Host
    Write-Host "USAGE:" -ForegroundColor $Yellow
    Write-Host "    .\manage.ps1 [COMMAND] [OPTIONS]"
    Write-Host
    Write-Host "COMMANDS:" -ForegroundColor $Yellow
    Write-Host "    start [service]     Start service or all services" -ForegroundColor $Green
    Write-Host "    stop [service]      Stop service or all services" -ForegroundColor $Green
    Write-Host "    restart [service]   Restart service or all services" -ForegroundColor $Green
    Write-Host "    status              Show status of all services" -ForegroundColor $Green
    Write-Host "    logs [service] [lines] Show logs for service (default: 50 lines)" -ForegroundColor $Green
    Write-Host "    update              Update all services" -ForegroundColor $Green
    Write-Host "    cleanup             Clean unused Docker resources" -ForegroundColor $Green
    Write-Host "    backup              Create backup of configurations" -ForegroundColor $Green
    Write-Host "    help                Show this help message" -ForegroundColor $Green
    Write-Host
    Write-Host "EXAMPLES:" -ForegroundColor $Yellow
    Write-Host "    .\manage.ps1 start              # Start all services"
    Write-Host "    .\manage.ps1 start traefik      # Start only Traefik"
    Write-Host "    .\manage.ps1 logs immich-server 100  # Show last 100 lines"
    Write-Host "    .\manage.ps1 status             # Show status of all services"
}

# ================================
# MAIN LOGIC
# ================================

Set-Location $ScriptDir

# Ensure Docker is installed and running
Ensure-Docker

switch ($Command.ToLower()) {
    "start" {
        if (-not (Test-Requirements)) { exit 1 }
        if (-not (Test-EnvFile)) { exit 1 }
        
        if ($Service) {
            Start-Service $Service
        } else {
            Start-AllServices
        }
    }
    
    "stop" {
        if ($Service) {
            Stop-Service $Service
        } else {
            Stop-AllServices
        }
    }
    
    "restart" {
        if (-not (Test-Requirements)) { exit 1 }
        if (-not (Test-EnvFile)) { exit 1 }
        
        if ($Service) {
            Stop-Service $Service
            Start-Service $Service
        } else {
            Stop-AllServices
            Start-AllServices
        }
    }
    
    "status" {
        Show-Status
    }
    
    "logs" {
        $ServiceName = if ($Service) { $Service } else { "traefik" }
        Show-Logs $ServiceName $Lines
    }
    
    "update" {
        if (-not (Test-Requirements)) { exit 1 }
        Update-AllServices
    }
    
    "cleanup" {
        Invoke-Cleanup
    }
    
    "backup" {
        New-Backup
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Error "Unknown command: $Command"
        Write-Host
        Show-Help
        exit 1
    }
}
