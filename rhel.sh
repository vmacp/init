#!/bin/bash
set -euo pipefail

RC=0

function log {
    local level="$1" && shift
    declare -A color
    color['info']='\033[1;32m'
    color['warning']='\033[1;33m'
    color['error']='\033[1;31m'
    echo -e "${color[$level]}${level^^} - $*\033[0m"
}

log info 'Install common packages'

common_packages=(
    zsh
    pass
    bat
    dmenu
    gh
    xdotool
    ksnip
    htop
    ShellCheck
    gitk
    jfrog-cli
    yamllint
    copyq
    sysstat
    figlet
)

# See https://github.com/pyenv/pyenv/wiki#suggested-build-environment
pyenv_dependencies=(
    gcc
    make
    patch
    zlib-devel
    bzip2
    bzip2-devel
    readline-devel
    sqlite
    sqlite-devel
    openssl-devel
    tk-devel
    libffi-devel
    xz-devel
)

nvim_dependencies=(
    lua5.1
    luarocks
    tree-sitter-cli
    ripgrep
    fd-find
)

packages=("${common_packages[@]}" "${pyenv_dependencies[@]}" "${nvim_dependencies[@]}")

sudo true

for package in "${packages[@]}"; do
    log info "Install $package"

    if rpm -qa name="$package" | grep -q .; then
        echo "Package $package already installed"
        continue
    fi

    if sudo dnf install -y "$package"; then
        echo Done
    else
        RC=1
        log error "Error during $package installation"
    fi
done

if [[ -f /etc/motd_iris_default ]]; then
    log info 'Remove motd file'
    sudo mv /etc/motd_iris_default ~
fi

log info 'Prepare ssh'
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

if [[ "$RC" -eq 0 ]]; then
    log info 'All set!'
else
    log error 'Something went wrong'
fi

exit "$RC"
