# Minecraft Server Management Commands

This collection of shell scripts provides an easy-to-use interface for managing Minecraft servers using Docker containers. The scripts integrate with the [minecraft-server](https://github.com/energypatrikhu/minecraft-server) project.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Available Commands](#available-commands)
  - [mc.install](#mcinstall)
  - [mc.add](#mcadd)
  - [mc.start](#mcstart)
  - [mc.update](#mcupdate)
- [Autocomplete](#autocomplete)
- [Directory Structure](#directory-structure)
- [Environment Variables](#environment-variables)
- [Backup Configuration](#backup-configuration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- Bash shell
- EPX shell scripts framework

## Installation

### 1. Configure Minecraft Settings

Create a configuration file at `${EPX_HOME}/.config/minecraft.config`:

```bash
# Path where the minecraft-server project will be cloned
MINECRAFT_DIR="/path/to/minecraft-project"
```

### 2. Install the Minecraft Project

Run the installation command:

```bash
mc.install
```

This will:
- Clone the [minecraft-server](https://github.com/energypatrikhu/minecraft-server) repository
- Set up the project directory structure
- Display next steps for configuration

### 3. Configure CurseForge API Key

After installation, set up your CurseForge API key:

```bash
echo "YOUR_API_KEY_HERE" > ${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt
```

## Configuration

The configuration file `${EPX_HOME}/.config/minecraft.config` contains:

| Variable | Description | Example |
|----------|-------------|---------|
| `MINECRAFT_DIR` | Base directory for Minecraft servers | `/opt/minecraft-servers` |

## Available Commands

### mc.install

**Description:** Clones the minecraft-server project from GitHub and sets up the initial directory structure.

**Usage:**
```bash
mc.install
```

**What it does:**
- Validates that the configuration file exists
- Clones the minecraft-server repository to `MINECRAFT_DIR`
- Creates necessary directory structure
- Provides post-installation instructions

**Output:**
```
Minecraft project install completed successfully.
You can now configure your Minecraft servers.
To pull changes from git, use 'mc.update'.

Minecraft project directory is located at /path/to/minecraft/servers
Setup the curseforge api key in /path/to/minecraft/servers/internals/secrets/curseforge_api_key.txt
Create a new server, use the command: mc.add <server_type> <server_name>
To show available servers and usage, use the command: mc.list
To start a server, use the command: mc.start <server_name>
```

---

### mc.add

**Description:** Creates a new Minecraft server instance from a template.

**Usage:**
```bash
mc.add <server_type> <server_name>
```

**Arguments:**
- `server_type`: The type of Minecraft server (e.g., vanilla, forge, fabric, paper)
- `server_name`: A custom name for your server instance

**What it does:**
- Creates a new server directory with the naming pattern: `{server_type}_{server_name}`
- Sets up the following directory structure:
  ```
  {server_type}_{server_name}/
  ├── data/                    # Server data directory
  ├── extras/                  # Additional files
  │   ├── configs/            # Custom configuration files
  │   ├── data/               # Extra data files
  │   ├── mods/               # Manual mod installations
  │   └── plugins/            # Manual plugin installations
  ├── config.env              # Environment variables for the server
  ├── mods.curseforge.txt     # CurseForge mod list
  ├── mods.modrinth.txt       # Modrinth mod list
  ├── ops.txt                 # Server operators list
  └── whitelist.txt           # Whitelisted players
  ```
- Populates configuration files from templates

**Example:**
```bash
mc.add fabric my-survival-server
# Creates: fabric_my-survival-server/
```

**Available Server Types:**
To see all available server types, run the command without arguments:
```bash
mc.add
```

Common types include:
- `vanilla` - Standard Minecraft server
- `fabric` - Fabric modded server
- `forge` - Forge modded server
- `paper` - Paper (optimized) server
- `spigot` - Spigot server
- `purpur` - Purpur server

---

### mc.start

**Description:** Starts a Minecraft server using Docker Compose.

**Usage:**
```bash
mc.start <server_directory>
```

**Arguments:**
- `server_directory`: The full server directory name (e.g., `fabric_my-survival-server`)

**What it does:**
- Validates the server directory exists
- Reads the server configuration from `config.env`
- Checks if backup is enabled
- Creates a Docker Compose project with the name: `mc_{server_directory}`
- Starts the Docker containers:
  - Minecraft server container (using itzg/minecraft-server)
  - Backup container (if enabled)
- Displays environment variables being used

**Example:**
```bash
mc.start fabric_my-survival-server
```

**Output:**
```
Starting Minecraft Server
> Backup is enabled
> Environment Variables:
  - VERSION=1.20.4
  - TYPE=FABRIC
  - MEMORY=4G
  - SERVER_TYPE = fabric
  - SERVER_DIR = fabric_my-survival-server
Minecraft server 'fabric_my-survival-server' started successfully.
```

**Docker Compose Profiles:**
The command automatically determines which Docker Compose files to use:
- With backup: Uses `itzg-config.yml`, `itzg-mc-backup.yml`, and `itzg-mc.yml`
- Without backup: Uses `itzg-config.yml` and `itzg-mc.yml`

---

### mc.update

**Description:** Updates the minecraft-server project by pulling the latest changes from GitHub.

**Usage:**
```bash
mc.update
```

**What it does:**
- Changes to the Minecraft project directory
- Runs `git pull` to fetch the latest updates
- Updates templates, scripts, and configurations

**Example:**
```bash
mc.update
```

**Output:**
```
Already up to date.
Minecraft project updated successfully.
```

**When to use:**
- When new server templates are available
- When bug fixes or improvements are released
- Periodically to stay up-to-date with the project

---

## Autocomplete

The scripts include bash autocomplete functionality for enhanced usability:

### Autocomplete for Server Directories
- `mc.start` - Shows available server directories
- `mc.up` - Shows available server directories

### Autocomplete for Running Containers
- `mc.restart` - Shows running Minecraft containers
- `mc.stop` - Shows running Minecraft containers
- `mc.rm` - Shows Minecraft containers

### Autocomplete for Server Types
- `mc.add` - Shows available server type templates

## Directory Structure

After installation and creating a server, your directory structure will look like:

```
${MINECRAFT_DIR}/
├── internals/
│   ├── secrets/
│   │   └── curseforge_api_key.txt
│   ├── templates/
│   │   ├── platforms/          # Server type templates
│   │   ├── backup              # Backup configuration template
│   │   ├── properties          # Server properties template
│   │   └── mods/
│   │       ├── curseforge      # CurseForge mods template
│   │       └── modrinth        # Modrinth mods template
│   ├── itzg-config.yml         # Base Docker Compose config
│   ├── itzg-mc-backup.yml      # Backup service config
│   └── itzg-mc.yml             # Minecraft server config
└── servers/
    └── {server_type}_{date}_{name}/
        ├── data/               # Minecraft server data
        ├── extras/             # Additional files
        ├── config.env          # Server environment variables
        ├── mods.curseforge.txt # CurseForge mod IDs
        ├── mods.modrinth.txt   # Modrinth mod slugs
        ├── ops.txt             # Server operators
        └── whitelist.txt       # Whitelisted players
```

## Environment Variables

Each server has a `config.env` file that contains environment variables. Common variables include:

### Server Configuration
```bash
# Minecraft version
VERSION=1.20.4

# Server type (VANILLA, FABRIC, FORGE, PAPER, etc.)
TYPE=FABRIC

# Memory allocation
MEMORY=4G

# Server port
SERVER_PORT=25565
```

### Backup Configuration
```bash
# Enable/disable backups
BACKUP=true

# Backup interval (e.g., 2h, 30m)
BACKUP_INTERVAL=2h

# Number of backups to keep
BACKUP_PRUNE_DAYS=7
```

### Server Properties
```bash
# Server name
SERVER_NAME=My Minecraft Server

# Difficulty (peaceful, easy, normal, hard)
DIFFICULTY=normal

# Game mode (survival, creative, adventure)
MODE=survival

# Max players
MAX_PLAYERS=20

# View distance
VIEW_DISTANCE=10
```

For a complete list of available environment variables, refer to the [itzg/minecraft-server documentation](https://github.com/itzg/docker-minecraft-server).

## Backup Configuration

Backups are managed using the [itzg/mc-backup](https://github.com/itzg/docker-mc-backup) Docker image.

### Enable Backups

Set in your server's `config.env`:
```bash
BACKUP=true
BACKUP_INTERVAL=2h
BACKUP_PRUNE_DAYS=7
```

### Backup Location

Backups are stored in the server's `data/backups` directory by default.

### Manual Backup

To trigger a manual backup, you can exec into the backup container:
```bash
docker exec mc_{server_directory}-backup backup now
```

## Examples

### Example 1: Create a Fabric Modded Server

```bash
# Create the server
mc.add fabric creative-build

# Edit the configuration
nano ${MINECRAFT_DIR}/servers/fabric_creative-build/config.env

# Add some mods to mods.curseforge.txt
echo "531761" >> ${MINECRAFT_DIR}/servers/fabric_creative-build/mods.curseforge.txt  # WorldEdit

# Start the server
mc.start fabric_creative-build
```

### Example 2: Create a Paper Server with Backups

```bash
# Create the server
mc.add paper survival-world

# Enable backups in config.env
echo "BACKUP=true" >> ${MINECRAFT_DIR}/servers/paper_survival-world/config.env
echo "BACKUP_INTERVAL=1h" >> ${MINECRAFT_DIR}/servers/paper_survival-world/config.env

# Start the server
mc.start paper_survival-world
```

### Example 3: Update and Restart a Server

```bash
# Update the project to get latest features
mc.update

# Stop the server
docker compose -p mc_fabric_creative-build down

# Restart the server with updated configuration
mc.start fabric_creative-build
```

## Troubleshooting

### Error: Minecraft configuration file not found

**Problem:** The configuration file doesn't exist.

**Solution:**
```bash
mkdir -p ${EPX_HOME}/.config
echo 'MINECRAFT_DIR="/path/to/minecraft/servers"' > ${EPX_HOME}/.config/minecraft.config
```

### Error: Failed to clone the Minecraft server repository

**Problem:** Git clone failed.

**Solution:**
- Check your internet connection
- Verify Git is installed: `git --version`
- Check if the directory already exists and remove it if needed

### Error: Server directory does not exist

**Problem:** You're trying to start a server that hasn't been created.

**Solution:**
- List available servers: Run `mc.start` without arguments
- Create the server first: `mc.add <type> <name>`

### Container won't start

**Problem:** Docker container fails to start.

**Solution:**
- Check Docker logs: `docker logs mc_{server_directory}-server`
- Verify EULA is accepted in `config.env`: `EULA=TRUE`
- Check port conflicts: Ensure the `SERVER_PORT` isn't already in use
- Verify memory allocation: Ensure your system has enough RAM

### Mods not loading

**Problem:** Mods listed in `mods.curseforge.txt` or `mods.modrinth.txt` aren't loading.

**Solution:**
- Verify your CurseForge API key is set correctly
- Check the mod IDs are correct (numeric for CurseForge, slugs for Modrinth)
- Check container logs for download errors
- Ensure the mods are compatible with your Minecraft version

### Permission issues

**Problem:** Permission denied errors when accessing server files.

**Solution:**
- The server runs as a specific user inside the container
- Check file permissions in the `data` directory
- You may need to adjust ownership: `sudo chown -R $(id -u):$(id -g) ${MINECRAFT_DIR}/servers/{server_directory}/data`

## Additional Resources

- [minecraft-server Project Repository](https://github.com/energypatrikhu/minecraft-server)
- [itzg/minecraft-server Documentation](https://github.com/itzg/docker-minecraft-server)
- [itzg/mc-backup Documentation](https://github.com/itzg/docker-mc-backup)
- [CurseForge API](https://docs.curseforge.com/)
- [Modrinth API](https://docs.modrinth.com/)

## Contributing

If you find issues or have suggestions for improvements, please open an issue or pull request on the [minecraft-server repository](https://github.com/energypatrikhu/minecraft-server).

## License

These scripts are part of the EPX shell scripts framework. Refer to the main repository for license information.
