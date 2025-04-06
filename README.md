
# Docker Tor Proxy

This project is a simple script that allows you to configure Docker to route all external connections through the Tor network. The script automatically installs and configures the necessary services, enabling you to run and manage Docker with Tor seamlessly.

## Prerequisites

- **Tor** must be installed.
- **Docker** must be installed.
- Root (sudo) access is required to modify system configuration files.
- This script is optimized for Debian-based systems (e.g., Ubuntu, Debian).

## Tools Used

- **Tor**: An anonymity network that allows you to route your internet traffic through various nodes in the Tor network, ensuring privacy and security.
- **Torsocks**: A tool that forces network connections to go through Tor, enabling applications to use Tor for their network communications.
- **Docker**: A containerization platform that enables you to run applications in isolated environments (containers), making them portable and efficient.

### Why Use Tor for Docker?

Using Tor for Docker connections can be beneficial for several reasons:
- **Privacy and Anonymity**: All Docker network requests are routed through the Tor network, hiding your IP and location.
- **Bypass Censorship**: In countries with strict internet censorship, Tor allows you to bypass network restrictions and access Docker images and external services.
- **Security**: Tor adds an additional layer of security by masking your external connections and preventing your IP address from being exposed.

## Features

This script provides the following features:
- **Install Tor and Torsocks**: Installs and configures Tor and Torsocks to ensure that Docker routes all external network traffic through the Tor network.
- **Configure Docker Proxy Settings**: Automatically updates Docker's configuration to use the Tor network for all outgoing connections.
- **Control Docker Proxy Settings**: Manage the Docker Tor proxy setup with simple commands (start, stop, status, restart).

## Installation

To install and configure Docker to use Tor as a proxy, run the following command:

```bash
chmod +x docker-tor-proxy.sh
./docker-tor-proxy.sh install
```

This will install **Tor**, configure Docker to route traffic through **Tor**, and start the necessary services.

## Available Commands

You can manage the Docker Tor Proxy setup using the following commands:

### `start`

Start Docker with the Tor proxy configuration enabled:

```bash
./docker-tor-proxy.sh start
```

### `stop`

Stop Docker and disable the Tor proxy configuration:

```bash
./docker-tor-proxy.sh stop
```

### `status`

Check the current status of Docker and Tor services:

```bash
./docker-tor-proxy.sh status
```

### `restart`

Restart Docker with the Tor proxy configuration:

```bash
./docker-tor-proxy.sh restart
```

### `check-tor`

Check if the system is connected to the Tor network:

```bash
./docker-tor-proxy.sh check-tor
```

### `backup`

Create a backup of the current Docker proxy configuration:

```bash
./docker-tor-proxy.sh backup
```

### `restore`

Restore the Docker proxy configuration from the backup:

```bash
./docker-tor-proxy.sh restore
```

## How It Works

1. **Install Tor and Torsocks**: The script installs the necessary tools to enable the Tor network on your system.
2. **Configure Docker**: Docker's systemd service is configured to route all traffic through Tor using the `socks5h://127.0.0.1:9050` proxy.
3. **Manage Docker's Proxy Settings**: The script provides commands to enable, disable, check the status, and restart the Docker service with the Tor proxy.

## Troubleshooting

If you encounter any issues with the setup, ensure that:
- **Install Tor and Torsocks:** The script installs the necessary tools to enable the Tor network on your system.
- **Configure Docker:** Docker's systemd service is configured to route all traffic through Tor using the socks5h://127.0.0.1:9050 proxy.
- **Manage Docker's Proxy Settings:** The script provides commands to enable, disable, check the status, and restart the Docker service with the Tor proxy.

### Common Issues:
- **Tor is not running**: Ensure that the Tor service is started with the following command:
  ```bash
  sudo systemctl start tor
  ```
- **Docker not restarting properly**: Restart Docker using the following command:
  ```bash
  sudo systemctl restart docker
  ```
- **Root access needed**: Ensure that you are using `sudo` where required for modifying system configurations.

## Backup and Restore

Before applying changes, it is recommended to back up your Docker configuration. You can restore the previous Docker proxy settings using the `restore` command:

```bash
./docker-tor-proxy.sh restore
```

## Security Considerations

- Use this script responsibly and legally. Tor is a powerful tool for privacy but must be used with care.
- Ensure that you understand the security implications of routing all traffic through Tor, especially if used in production environments.

## License

This project is open-source and distributed under the MIT License.
