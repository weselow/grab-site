#!/bin/bash
sudo apt-get update
sudo apt-get install --no-install-recommends \
    git build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libffi-dev libxml2-dev libxslt1-dev libre2-dev pkg-config
wget https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer

echo
echo Pause...
sleep 10
chmod +x pyenv-installer
./pyenv-installer
~/.pyenv/bin/pyenv install 3.7.5
echo "PATH=\"$PATH:$HOME/gs-venv/bin\"" >> ~/.bashrc

echo
echo Pause...
sleep 10

~/.pyenv/versions/3.7.5/bin/python -m venv ~/gs-venv
~/gs-venv/bin/pip install --no-binary lxml --upgrade git+https://github.com/ArchiveTeam/grab-site
~/gs-venv/bin/pip install html5lib psutil

# add global stop list
# global2
# add symlink to grab-site settings dir