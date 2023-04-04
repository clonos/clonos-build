#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

. ${progdir}/config

# list zones
curl -s -H "X-API-Key: ${API_KEY}" http://127.0.0.1:8081/api/v1/servers/localhost

# get specific zone
curl -s -H "X-API-Key: ${API_KEY}" http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.org

# get metadata specific zone
curl -s -H "X-API-Key: ${API_KEY}" http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.org/metadata
