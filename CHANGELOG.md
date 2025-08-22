# 🔄 Changelog

All notable changes to this homelab project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive management script (`manage.sh`)
- Environment variable support for secure configuration
- Health checks for all critical services
- Advanced Traefik configuration with SSL/TLS
- Development override configurations
- Comprehensive troubleshooting guide
- Security hardening for all services
- Migration guide for unified Docker Compose

### Changed
- **BREAKING**: Consolidated all services into single Docker Compose file
- Moved sensitive data to environment variables
- Improved Docker Compose configurations
- Enhanced security with proper file permissions
- Updated documentation with detailed setup guide
- Simplified project structure

### Removed
- `dyndns/` directory (integrated into base-services)
- `nginx/` directory (integrated into base-services)  
- `immich/compose.yml` (integrated into base-services)
- Legacy configuration files and directories

### Security
- Removed hardcoded passwords and tokens
- Added comprehensive `.gitignore` for sensitive files
- Implemented security headers in Traefik
- Added rate limiting and security middlewares

## [1.0.0] - 2025-08-22

### Added
- Initial homelab setup with Docker Compose
- Base services: Traefik, Portainer, Heimdall, Uptime Kuma, Watchtower, Pi-hole, Vaultwarden, Homer
- Dynamic DNS with Cloudflare
- Immich photo backup solution
- Nginx Proxy Manager
- Basic documentation and README

### Infrastructure
- Docker-based containerization
- Reverse proxy with Traefik
- Automated SSL certificate management
- Container monitoring and management
- DNS and ad-blocking capabilities
- Password management solution
