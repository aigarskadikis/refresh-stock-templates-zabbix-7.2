#!/bin/bash

# remove old dir. start fresh
rm -rf /tmp/7.2.zip
rm -rf /tmp/zabbix-release-7.2

# generate a SID by using:
# "Administration" => "General" => "API tokens"
SID=$(cat ~/.z72auth)

# API endpoint
JSONRPC=$(cat ~/.z72url)

# download latest 7.2 branch
curl -kL https://github.com/zabbix/zabbix/archive/refs/heads/release/7.2.zip -o /tmp/7.2.zip

# unzip
cd /tmp
unzip 7.2.zip

# go back to previous directory where PHP program is located
cd -

# start template import
find /tmp/zabbix-release-7.2/templates/media -type f -name '*.yaml' | \
while IFS= read -r MEDIA
do {
php media_type.php $SID $JSONRPC $MEDIA | jq .result | grep "true"
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo $MEDIA
} done

