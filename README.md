# EPX Shell Scripts

> **Heads up:** This is a hobby project. While useful, it may contain bugs or breaking changes. Use at your own risk and always review scripts before running them on important systems.

EPX is a collection of shell scripts and utilities designed to simplify and automate common system administration tasks on Linux. It provides handy commands for working with Docker, Python environments, file management, firewall (ufw), and more.

## Features
- Docker management helpers
- Python virtual environment and package management
- File operations (archive, copy, move, etc.)
- UFW firewall rule management
- Utility scripts for backup and updates

## Installation
```bash
curl https://raw.githubusercontent.com/energypatrikhu/epx/refs/heads/main/install.sh | sudo bash -
```

## Updating
To update EPX to the latest version, simply run:
```bash
epx self-update
```
This command will fetch and apply the latest changes from the repository.

## Usage
After installation, use the provided commands and aliases to streamline your workflow. See the `commands/` and `helpers/` directories for available scripts.

## Configuration Directory

EPX stores its configuration and data in the `.config` directory located inside the `EPX_HOME` directory. These are not user-specific configs, but are used by EPX to manage its own settings and persistent data. Example configuration files with the `.example` extension are provided in this directory to show what options are available and how to customize them if needed.

## Templates

EPX includes a set of templates to help you quickly create common configuration or script files. These templates can be copied and customized for your own use. Look for template files in the project directories, and use them as a starting point for your own scripts or configurations.

---
This project is intended for users comfortable with the Linux command line.
