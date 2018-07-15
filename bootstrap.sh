#!/bin/sh

remote_url="https://github.com/akirak/foundation.git"
remote_branch="master"

default_repository_path="$HOME/foundation"

function has_executable () {
    which $1 >/dev/null 2>/dev/null
}

function already_cloned () {
    has_executable git &&
        [ $(git config --local remote.origin.url) = ${remote_url} ]
}

# Manjaro Linux
if [ -f /etc/manjaro-release ]; then
    # For simplicity, this script needs to be run as a normal user
    if [ $(id -u) != 1000 ]; then
        echo "You must run this script as a user of UID 1000." >&2
        exit 1
    fi
    # Run already_cloned function to get the context as an exit status
    already_cloned
    if [ $? -gt 0 ]; then
        sudo pacman -Sy --noconfirm --needed git || exit 1
        git clone -b ${remote_branch} ${remote_url} \
            ${default_repository_path} || exit 1
        cd ${default_repository_path}
    fi
    sudo pacman -Sy --noconfirm --needed \
         openssh ansible base-devel yaourt || exit 1
else
    echo "This distribution is not supported." >&2
    exit 1
fi

cd ansible
ansible-playbook -c local -i localhost, install-as-user.yml
