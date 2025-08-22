#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Immich Setup...${NC}"

# Create library directory
echo -e "${YELLOW}Creating library directory...${NC}"
mkdir -p ./library

# Generate random JWT secret
JWT_SECRET=$(openssl rand -base64 32)

# Backup existing .env if it exists
if [ -f .env ]; then
    echo -e "${YELLOW}Backing up existing .env file...${NC}"
    mv .env .env.backup
fi

# Create new .env file
echo -e "${YELLOW}Creating .env file...${NC}"
cat > .env << EOL
# Database
DB_HOSTNAME=immich-postgres
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_DATABASE_NAME=immich

# Redis
REDIS_HOSTNAME=immich-redis

# Upload location
UPLOAD_LOCATION=./library

# JWT secret
JWT_SECRET=${JWT_SECRET}

# Immich version
NODE_ENV=production

# Optional: SMTP settings for email functionality
# SMTP_HOSTNAME=
# SMTP_PORT=587
# SMTP_USERNAME=
# SMTP_PASSWORD=
# SMTP_FROM_ADDRESS=

# PostgreSQL credentials
POSTGRES_PASSWORD=postgres
POSTGRES_USER=postgres
POSTGRES_DB=immich

# Optional: Machine Learning
ENABLE_MACHINE_LEARNING=true
EOL

# Set correct permissions
echo -e "${YELLOW}Setting correct permissions...${NC}"
chmod 600 .env
chmod +x "$(dirname "$0")/setup.sh"

# Start the services
echo -e "${YELLOW}Starting Docker containers...${NC}"
docker compose pull
docker compose up -d

# Check if services are running
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

if docker compose ps | grep -q "immich"; then
    echo -e "${GREEN}Immich has been successfully set up!${NC}"
    echo -e "${GREEN}You can access the web interface at: http://localhost:2283${NC}"
    echo -e "${GREEN}Please create an admin account on first access.${NC}"
else
    echo -e "\033[0;31mSome services might have failed to start. Please check 'docker compose logs' for details.${NC}"
fi
