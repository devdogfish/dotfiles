# dotfiles

My personal dotfiles and server setup scripts.

## Beszel

[Beszel](https://beszel.dev) is a lightweight server monitoring tool. The **hub** runs on one server with a public IP — it hosts the web UI, stores data, and uses Caddy (via Docker) for HTTPS. Every server you want to monitor runs an **agent**, including the hub server itself. Agents on private servers connect back to the hub over Tailscale, so no public ports are needed on those machines. Physical machines get S.M.A.R.T. disk monitoring enabled; cloud VMs do not.

#### `beszel-hub-setup.sh`

Sets up the Beszel hub on a server with a public IP. Installs Docker and Tailscale if needed, configures Caddy as a Docker container, and starts the hub and local agent.

```bash
bash <(curl -fsSL "https://raw.githubusercontent.com/devdogfish/dotfiles/main/beszel-hub-setup.sh?$(date +%s)")
```

#### `beszel-agent-setup.sh`

Sets up a Beszel agent on any server. Installs Docker and Tailscale if needed, handles S.M.A.R.T. monitoring for physical machines, and auto-starts the agent.

```bash
bash <(curl -fsSL "https://raw.githubusercontent.com/devdogfish/dotfiles/main/beszel-agent-setup.sh?$(date +%s)")
```

## Downloading and running scripts

### Download a script without running it

```bash
curl -fsSL "https://raw.githubusercontent.com/devdogfish/dotfiles/main/SCRIPT_NAME.sh?$(date +%s)" -o SCRIPT_NAME.sh
```

### Run a script directly

```bash
bash <(curl -fsSL "https://raw.githubusercontent.com/devdogfish/dotfiles/main/beszel-hub-setup.sh?$(date +%s)")
```
