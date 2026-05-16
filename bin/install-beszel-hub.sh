#!/bin/bash
set -e

echo "================================"
echo "  Beszel Hub Setup"
echo "================================"
echo ""

# Prompt for domain
read -p "Enter your Beszel domain: " DOMAIN
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
else
    echo ">> Tailscale already installed, skipping."
fi

# Create directories
mkdir -p ~/beszel/caddy && cd ~/beszel

# Write Caddyfile
cat > caddy/Caddyfile << EOF
${DOMAIN} {
    request_body {
        max_size 10MB
    }
    reverse_proxy beszel:8090 {
        transport http {
            read_timeout 360s
        }
    }
}
EOF

# Write docker-compose.yml
cat > docker-compose.yml << EOF
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy/data:/data
      - ./caddy/config:/config
    depends_on:
      - beszel

  beszel:
    image: henrygd/beszel:latest
    container_name: beszel
    restart: unless-stopped
    expose:
      - "8090"
    volumes:
      - ./beszel_data:/beszel_data
      - ./beszel_socket:/beszel_socket
    environment:
      APP_URL: "https://${DOMAIN}"

  beszel-agent:
    image: henrygd/beszel-agent:latest
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./beszel_socket:/beszel_socket
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      LISTEN: /beszel_socket/beszel.sock
      KEY: "\${BESZEL_KEY}"
EOF

# Write placeholder .env
echo "BESZEL_KEY=" > .env

# Start hub and caddy only
echo ">> Starting Beszel hub and Caddy..."
docker compose up -d caddy beszel

echo ""
echo "================================"
echo "  Hub is running!"
echo ""
echo "  1. Open https://${DOMAIN} in your browser"
echo "     (may take 30-60 seconds for TLS cert)"
echo "  2. Create your admin account"
echo "  3. Click '+ Add System'"
echo "     - Name: hub (or whatever you call this server)"
echo "     - Host: /beszel_socket/beszel.sock"
echo "     - Port: 45876"
echo "  4. Copy the Public Key (ssh-ed25519 AAAA...)"
echo "================================"
echo ""

# Wait for user to get the key
read -p "Paste the Public Key from the Beszel UI here: " BESZEL_KEY

# Update .env with real key
echo "BESZEL_KEY=${BESZEL_KEY}" > .env

# Start local agent
echo ">> Starting local agent..."
docker compose up -d beszel-agent

echo ""
echo "================================"
echo "  All done!"
echo "  Check https://${DOMAIN} in ~30 seconds"
echo "  The hub server should show as Up"
echo "================================"
docker compose logs beszel-agent