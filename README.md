# hardware/mysql-glacier

![mysql-glacier](https://i.imgur.com/sBd2xLA.png "mysql-glacier")

This tool provides a command line interface to create periodic backups of your MySQL databases and upload
them to Amazon Glacier for archiving and long-term backup.

#### IN DEVELOPEMENT !

### Requirement

- Amazon Web Services account
- Docker 1.0 or higher
- MySQL database

### Installation

```
docker pull hardware/mysql-glacier
mkdir -p ~/.config/mysql-glacier
```

Inside your shell config file, add a new alias :

```
alias glacier='docker run --rm -i \
  --env-file ~/.config/mysql-glacier/.aws \
  -v ~/.cache/glacier-cli:/root/.cache/glacier-cli \
  hardware/mysql-glacier'
```

Create an `.aws` file with your AWS credentials, you’ll need retrieve your **Access Key ID**
and **Secret Access Key** from the web-based console, use the IAM module (Identity
and Access Management).

```
# ~/.config/mysql-glacier/.aws

AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxx
```

Don't forget to set permissions and immutable bit, then source your shell config file :

```
chmod 600 ~/.config/mysql-glacier/.aws
chattr +i ~/.config/mysql-glacier/.aws
. ~/.bashrc
```

### Environment variables

- **AWS_ACCESS_KEY_ID** = Amazon Access Key ID (**required**)
- **AWS_SECRET_ACCESS_KEY** = Amazon Secret Access Key (**required**)
- **GLACIER_VAULT_NAME** = Glacier vault name (*optional*, default: default)
- **DBHOST** = MySQL instance ip/hostname (*optional*, default: mysql)
- **DBPORT** = MySQL instance port (*optional*, default: 3306)
- **DBUSER** = MYSQL database username (**required**)
- **DBNAME** = MYSQL database name (**required**)
- **DBPASS** = MYSQL database password (**required**)
- **DBSITE** = MYSQL database website name (*optional*, default: main)

### Usage

If this is not already done, create your first vault :

```
glacier create <vault-name>
```

You can retrieve your vault list :

```
glacier list
```

Now, run a backup :

```
docker run --rm -i \
  --env-file ~/.config/mysql-glacier/.aws \
  -e "GLACIER_VAULT_NAME=myvault" \
  -e "DBHOST=mysqldb" \
  -e "DBPORT=3306" \
  -e "DBNAME=forum" \
  -e "DBUSER=forum" \
  -e "DBPASS=xxxxx" \
  -e "DBSITE=myAwesomeWebsite" \
  -v ~/.cache/glacier-cli:/root/.cache/glacier-cli \
  --link mysqldb:mysqldb \
  hardware/mysql-glacier

> Generating backup for mysqldb:3306/myAwesomeWebsite->forum
> Vault synchronisation
> Sending backup to your vault 'myvault'
> Clean local backup
> Done !
```

List all your backups :

```
glacier backup-list <vault-name>

myAwesomeWebsite-forum-2016-01-30_23-47.sql
myAwesomeWebsite-mail-2016-01-30_22-23.sql
myAwesomeWebsite-chat-2016-01-30_21-58.sql
```

Remove a backup :

```
glacier backup-delete <vault-name> <backup-name>
glacier backup-delete <vault-name> <id:xxxxxxxxx>
```