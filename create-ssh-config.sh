#!/bin/bash

HOST_NAME=$1
HOST_IP=$2
SSH_USER=$3
IDENTITY_FILE_PATH=$4
CONFIG_FILE_PATH=$5
IS_BASTION=$6

add_or_update_host() {
    local name=$1
    local ip=$2
    local user=$3
    local key_path=$4
    local cfg_path=$5
    local is_bastion=$6

    if [[ "$OSTYPE" == "darwin"* ]]; then
        SED_I_OPTION=(-i '')
    else
        SED_I_OPTION=(-i)
    fi

    # Add new entry for Bastion
    sed "${SED_I_OPTION[@]}" "/^Host ${name}\$/,/^$/d" "${cfg_path}"
    if [[ "${is_bastion}" == "true" ]]; then
        cat >> "${cfg_path}" <<EOL
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 120

Host ${name}
  HostName ${ip}
  User ${user}
  IdentityFile ${key_path}

EOL
    # GoPhish port forwarding
    elif [[ "${name}" == "gophish" ]]; then
        cat >> "${cfg_path}" <<EOL
Host ${name}
  HostName ${ip}
  User ${user}
  IdentityFile ${key_path}
  ProxyJump bastion
  LocalForward 3333 ${ip}:3333

EOL

    # RedELK port forwarding
    elif [[ "${name}" == "redelk" ]]; then
        cat >> "${cfg_path}" <<EOL
Host ${name}
  HostName ${ip}
  User ${user}
  IdentityFile ${key_path}
  ProxyJump bastion
  LocalForward 4430 ${ip}:443

EOL

    else
        cat >> "${cfg_path}" <<EOL
Host ${name}
  HostName ${ip}
  User ${user}
  IdentityFile ${key_path}
  ProxyJump bastion

EOL
    fi
}

add_or_update_host "${HOST_NAME}" "${HOST_IP}" "${SSH_USER}" "${IDENTITY_FILE_PATH}" "${CONFIG_FILE_PATH}" "${IS_BASTION}"