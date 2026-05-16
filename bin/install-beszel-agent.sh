#!/bin/bash
set -e

echo "================================"
echo "  Beszel Agent Setup"
echo "================================"
echo ""

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo ">> Docker not found — installing..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
    newgrp docker
else
    echo ">> Docker already installed, skipping."
fi

# Install Tailscale if not present
if ! command -v tailscale &> /dev/null; then
    echo ">> Tailscale not found — installing..."
    curl -fsSL https://tailscale.com/install.sh | sudo sh
    echo ""
    echo ">> Authenticate Tailscale — open the URL below in your browser:"
    sudo tailscale up
    echo ""
else
    echo ">> Tailscale already installed, skipping."
fi

# Show Tailscale IP
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
echo ""
echo ">> This server's Tailscale IP: ${TAILSCALE_IP}"
echo "   Use this as the Host/IP when adding the system in the Beszel UI."
echo ""

# Prompt for key
read -p "Paste the Public Key (ssh-ed25519 AAAA...) from the Beszel UI: " BESZEL_KEY
echo ""

# Ask if physical machine
read -p "Is this a physical machine (not a cloud VM)? [y/n]: " IS_PHYSICAL
echo ""

# Build compose config based on machine type
SMART_CONFIG=""
IMAGE="henrygd/beszel-agent:latest"

if [[ "$IS_PHYSICAL" == "y" ]]; then
    echo ">> Available disks:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep disk
    echo ""
    read -p "Enter disk name to monitor with S.M.A.R.T. (e.g. sda): " DISK
    IMAGE="henrygd/beszel-agent:alpine"
    SMART_CONFIG="    cap_add:
      - SYS_RAWIO
      - SYS_ADMIN
    devices:
      - /dev/${DISK}:/dev/${DISK}"
fi

# Create directory
mkdir -p ~/beszel-agent && cd ~/beszel-agent

# Write .env
echo "BESZEL_KEY=${BESZEL_KEY}" > .env

# Write docker-compose.yml
cat > docker-compose.yml << EOF
services:
  beszel-agent:
    image: ${IMAGE}
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
${SMART_CONFIG}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      PORT: "45876"
      KEY: "\${BESZEL_KEY}"
EOF

# Start the agent
docker compose up -d

echo ""
echo "================================"
echo "  Agent started!"
echo "  Tailscale IP: ${TAILSCALE_IP}"
echo "  Check the Beszel dashboard in ~30 seconds"
echo "================================"
docker compose logs