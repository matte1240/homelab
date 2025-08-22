# 🛠️ Homelab Troubleshooting Guide

## 🚨 Common Issues and Solutions

### 🔌 **Connection Issues**

#### Service not accessible via `.local` domain
**Problem**: Cannot access services via `traefik.local`, `portainer.local`, etc.

**Solutions**:
1. **Add entries to hosts file**:
   ```bash
   # Linux/Mac: /etc/hosts
   # Windows: C:\Windows\System32\drivers\etc\hosts
   127.0.0.1 traefik.local
   127.0.0.1 portainer.local
   127.0.0.1 heimdall.local
   127.0.0.1 uptime.local
   127.0.0.1 pihole.local
   127.0.0.1 vault.local
   127.0.0.1 home.local
   ```

2. **Configure router DNS**:
   - Set Pi-hole as primary DNS
   - Add local DNS entries in router

3. **Use IP addresses directly**:
   ```bash
   # Check container ports
   docker ps --format "table {{.Names}}\t{{.Ports}}"
   ```

#### Port conflicts
**Problem**: `bind: address already in use`

**Solution**:
```bash
# Check what's using the port
sudo netstat -tulpn | grep :80
sudo lsof -i :80

# Stop conflicting service
sudo systemctl stop apache2  # Example
```

### 🐳 **Docker Issues**

#### Container fails to start
**Problem**: Container exits immediately

**Diagnosis**:
```bash
# Check container logs
docker logs container_name

# Check container status
docker ps -a

# Inspect container configuration
docker inspect container_name
```

**Common causes**:
- Missing environment variables
- Permission issues
- Port conflicts
- Volume mount problems

#### Out of disk space
**Problem**: Docker runs out of space

**Solution**:
```bash
# Check Docker disk usage
docker system df

# Clean up
docker system prune -a -f
docker volume prune -f

# Remove specific images
docker rmi $(docker images -q)
```

### 🔐 **Permission Issues**

#### Volume permission denied
**Problem**: Container can't write to mounted volumes

**Solution**:
```bash
# Fix ownership (replace 1000:1000 with your user:group)
sudo chown -R 1000:1000 ./data_directory

# Or use Docker user mapping
# In compose.yml:
user: "1000:1000"
```

#### Pi-hole permission issues
**Problem**: Pi-hole can't write to config directories

**Solution**:
```bash
# Create directories with correct permissions
mkdir -p ./pihole/etc-pihole ./pihole/etc-dnsmasq.d
sudo chown -R 999:999 ./pihole/
```

### 🌐 **Network Issues**

#### Services can't communicate
**Problem**: Container-to-container communication fails

**Solution**:
```bash
# Check Docker networks
docker network ls
docker network inspect bridge

# Use container names for internal communication
# Instead of: localhost:3306
# Use: database:3306
```

#### DNS resolution problems
**Problem**: External DNS queries fail

**Solution**:
```bash
# Check DNS in container
docker exec container_name nslookup google.com

# Configure DNS in compose.yml
dns:
  - 8.8.8.8
  - 1.1.1.1
```

### 🔑 **Authentication Issues**

#### Can't login to services
**Problem**: Forgot password or login fails

**Solutions**:

**Pi-hole**:
```bash
# Reset password
docker exec -it pihole pihole -a -p newpassword
```

**Portainer**:
```bash
# Reset admin password
docker stop portainer
docker run --rm -v portainer_data:/data portainer/helper-reset-password
docker start portainer
```

**Vaultwarden**:
```bash
# Check logs for admin token
docker logs vaultwarden
```

### 📊 **Performance Issues**

#### High CPU/Memory usage
**Problem**: Container consuming too many resources

**Diagnosis**:
```bash
# Check resource usage
docker stats

# Check system resources
htop
free -h
df -h
```

**Solutions**:
- Add resource limits in compose.yml:
  ```yaml
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
  ```

#### Slow response times
**Problem**: Services respond slowly

**Solutions**:
1. Check disk I/O: `iotop`
2. Check network: `iftop`
3. Optimize Docker:
   ```bash
   # Use overlay2 storage driver
   # Add to /etc/docker/daemon.json:
   {
     "storage-driver": "overlay2"
   }
   ```

### 🔄 **Update Issues**

#### Update breaks service
**Problem**: Service fails after update

**Solution**:
```bash
# Rollback to previous version
docker-compose down
docker pull service:previous-tag
docker-compose up -d

# Check breaking changes in release notes
```

#### Database migration fails
**Problem**: Database schema update fails

**Solution**:
```bash
# Backup database first
docker exec postgres pg_dump -U user database > backup.sql

# Restore if needed
docker exec -i postgres psql -U user database < backup.sql
```

## 🔧 **Diagnostic Commands**

### Quick Health Check
```bash
# Run the management script status
./manage.sh status

# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check Docker daemon
systemctl status docker
```

### Detailed Diagnostics
```bash
# System resources
df -h                    # Disk space
free -h                  # Memory
top                      # CPU usage

# Docker information
docker info              # Docker system info
docker version           # Docker version
docker system df         # Docker disk usage

# Network diagnostics
ss -tulpn               # Open ports
ip route                # Routing table
```

### Log Analysis
```bash
# Container logs
docker logs --tail 100 -f container_name

# System logs
journalctl -u docker -f          # Docker daemon logs
tail -f /var/log/syslog          # System logs

# Service-specific logs
./manage.sh logs service_name 100
```

## 📞 **Getting Help**

1. **Check the logs** first with `./manage.sh logs service_name`
2. **Search GitHub issues** in the official repositories
3. **Check documentation** for each service
4. **Ask for help** with specific error messages and logs

## 🔗 **Useful Resources**

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Pi-hole Documentation](https://docs.pi-hole.net/)
- [Immich Documentation](https://immich.app/docs/overview/introduction)
