#!/bin/sh

# Specify a source for installation from a remote repository
remote_url="https://github.com/akirak/foundation.git"
remote_branch="master"

# The default clone destination of the repository
default_repository_path="$HOME/foundation"

# A function to check if an executable exists in $PATH
function has_executable () {
    which $1 >/dev/null 2>/dev/null
}

# A function to check if the user is inside the configuration repository
function already_cloned () {
    has_executable git &&
        [ $(git config --local remote.origin.url) = ${remote_url} ]
}

# A function to clone this repository.
function clone_this_repository () {
    git clone -b ${remote_branch} ${remote_url} \
        ${default_repository_path}
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
        # Install git and clone this repository
        sudo pacman -Sy --noconfirm --needed git || exit 1
        clone_this_repository || exit 1
        cd ${default_repository_path}
    fi
    # Install openssh as it is necessary even if it is a client
    # Install yaourt and base-devel for an AUR support
    # Install ansible to run the playbook
    sudo pacman -Sy --noconfirm --needed \
         openssh ansible base-devel yaourt || exit 1
else
    # Fail if the current distribution is none of the above
    echo "This distribution is not supported." >&2
    exit 1
fi

cd ansible
ansible-playbook -c local -i localhost, install-as-user.yml
