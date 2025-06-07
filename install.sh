#!/bin/bash

# RustDesk Server Installation Script for Ubuntu
# This script installs and configures RustDesk server using Docker

set -e

echo "=== RustDesk Server Installation for Ubuntu ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_warning "Running as root. This is not recommended for production environments."
   print_warning "Consider creating a dedicated user for better security."
   sleep 2
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_status "Docker not found. Installing Docker..."
    
    # Update package index
    sudo apt update
    
    # Install required packages
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    print_status "Docker installed successfully!"
    print_warning "You may need to log out and log back in for Docker group membership to take effect."
else
    print_status "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_status "Docker Compose not found. Installing Docker Compose..."
    
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    print_status "Docker Compose installed successfully!"
else
    print_status "Docker Compose is already installed."
fi

# Get public IP address
print_status "Detecting public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || curl -s icanhazip.com)

if [ -z "$PUBLIC_IP" ]; then
    print_error "Could not detect public IP address automatically."
    read -p "Please enter your public IP address: " PUBLIC_IP
fi

print_status "Using public IP: $PUBLIC_IP"

# Update docker-compose.yml with the actual IP
print_status "Updating docker-compose.yml with your public IP..."

# Create backup of original file
cp docker-compose.yml docker-compose.yml.backup

# Replace YOUR_PUBLIC_IP with actual IP
sed -i "s/YOUR_PUBLIC_IP/$PUBLIC_IP/g" docker-compose.yml

print_status "docker-compose.yml updated successfully!"

# Create data directory for persistent storage
print_status "Creating data directories..."
mkdir -p data

# Configure firewall (if ufw is active)
if sudo ufw status | grep -q "Status: active"; then
    print_status "Configuring firewall rules..."
    sudo ufw allow 21115/tcp
    sudo ufw allow 21116/tcp
    sudo ufw allow 21116/udp
    sudo ufw allow 21117/tcp
    sudo ufw allow 21118/tcp
    sudo ufw allow 21119/tcp
    print_status "Firewall rules added for RustDesk ports."
fi

# Start RustDesk server
print_status "Starting RustDesk server..."
docker-compose up -d

# Wait for containers to be ready
print_status "Waiting for containers to start..."
sleep 10

# Check container status
print_status "Checking container status..."
docker-compose ps

# Display connection information
echo ""
echo "=========================================="
echo "RustDesk Server Installation Complete!"
echo "=========================================="
echo ""
echo "Server Details:"
echo "- Public IP: $PUBLIC_IP"
echo "- hbbs port: 21116 (UDP), 21115 (TCP)"
echo "- hbbr port: 21118 (TCP)"
echo "- Relay port: 21117 (TCP)"
echo ""
echo "Client Configuration:"
echo "- ID Server: $PUBLIC_IP:21116"
echo "- Relay Server: $PUBLIC_IP:21117"
echo ""
echo "Commands:"
echo "- View logs: docker-compose logs -f"
echo "- Stop server: docker-compose down"
echo "- Start server: docker-compose up -d"
echo "- Restart server: docker-compose restart"
echo ""
echo "Key file location: ./data/"
echo ""
print_status "RustDesk server is now running!"
