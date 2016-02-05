#!/bin/bash

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"

# Boto configuration
cat > ~/.boto <<EOF
[Credentials]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

if [ -z "$DBNAME" ]; then

  /bin/bash vault.sh "$1" "$2" "$3"

else

  glacier vault list &> /dev/null

  if [ "$?" -ne 0 ]; then
    echo -e "${CRED}\n/!\ Vault not created or invalid AWS credentials !${CEND}" 1>&2
    exit 1
  fi

  datetime="$(date +'%Y-%m-%d_%H-%M')"
  filename="${DBSITE}-${DBNAME}-${datetime}.sql"

  echo "> Generating backup for $DBHOST:$DBPORT/$DBSITE->$DBNAME"
  mysqldump -h "$DBHOST" -P "$DBPORT" -u "$DBUSER" --password="$DBPASS" "$DBNAME" > "$filename"

  echo "> Vault synchronisation"
  glacier vault sync --wait "$GLACIER_VAULT_NAME" &> /dev/null

  echo "> Sending backup to your vault '$GLACIER_VAULT_NAME'"
  glacier archive upload "$GLACIER_VAULT_NAME" "${filename}"

  echo "> Clean local archive"
  rm -rf "${filename}"

  echo -e "${CGREEN}> Done !${CEND}"
  exit 0

fi