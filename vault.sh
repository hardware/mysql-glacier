#!/bin/bash

action=$1
vaultName=$2
archiveName=$3

glacier vault list &> /dev/null

if [ "$?" -ne 0 ]; then
  echo -e "${CRED}\n/!\ Vault not created or invalid AWS credentials !${CEND}" 1>&2
  exit 1
fi

case "$action" in
  "create")
    glacier vault create "$vaultName"
    ;;
  "list")
    glacier vault list
    ;;
  "backup-list")
    glacier archive list "$vaultName"
    ;;
  "backup-delete")
    glacier archive delete "$vaultName" "$archiveName"
    ;;
  "backup-retrieve")
    glacier archive retrieve --wait "$vaultName" "$archiveName"
    ;;
  *)
    echo "Usage: $0 {create|list|backup-list|backup-delete|backup-retrieve}"
    exit 1
    ;;
esac