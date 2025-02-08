# Install
1. Clone the repository
    ```bash
    git clone https://github.com/energypatrikhu/epx.git /opt/epx
    ```
2. Add `. /opt/epx/epx.sh` to the beginning of `~/.bashrc`
    ```bash
    . /opt/epx/epx.sh
    ```
    ```bash
    nano ~/.bashrc
    ```
4. Run source
    ```bash
    source ~/.bashrc
    ```

# Crontab

### Debian
1. Run crontab editor
    ```bash
    crontab -e
    ```
2. Add the following line to the bottom
    ```bash
    0 0 * * * (cd /opt/epx && git reset --hard HEAD && git clean -f -d && git pull)
    ```
