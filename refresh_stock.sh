#!/bin/bash

# remove old dir. start fresh
rm -rf /tmp/7.2.zip
rm -rf /tmp/zabbix-release-7.2

mkdir -p /tmp/zabbix-release-7.2

# generate a SID by using:
# "Administration" => "General" => "API tokens"
SID=$(cat ~/.z72auth)

# Frontend endpoint
JSONRPC=$(cat ~/.z72url)/api_jsonrpc.php

# download latest 7.2 branch from github
#curl -kL https://github.com/zabbix/zabbix/archive/refs/heads/release/7.2.zip -o /tmp/7.2.zip
curl -kL "https://git.zabbix.com/rest/api/latest/projects/ZBX/repos/zabbix/archive?at=refs%2Fheads%2Frelease%2F7.2&format=zip" -o /tmp/zabbix-release-7.2/7.2.zip

# unzip
cd /tmp/zabbix-release-7.2
unzip 7.2.zip

# go back to previous directory where PHP program is located
cd -

# start template import
find /tmp/zabbix-release-7.2/templates -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php delete_missing.php $SID $JSONRPC $TEMPLATE | jq .result | grep "true" > /dev/null && echo "OK $TEMPLATE" 
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo "failed $TEMPLATE"
} done

find /tmp/zabbix-release-7.2/templates/media -type f -name '*.yaml' | \
while IFS= read -r MEDIA
do {
php media_type.php $SID $JSONRPC $MEDIA | jq .result | grep "true" > /dev/null && echo "OK $MEDIA"
# if 'true' not received the print the template name
[[ $? -ne 0 ]] && echo "failed $MEDIA"
} done

