#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

. ${progdir}/config

curl -s -H "X-API-Key: ${API_KEY}" -X PATCH -d '{"rrsets":[{"name":"mytest.example.org.","type":"TXT","ttl":3600,"changetype":"REPLACE","records":[{"content":"\"this is a test\"","set_ptr":false,"disabled":false}]}]}' http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.org
curl -s -H "X-API-Key: ${API_KEY}" -X PATCH -d '{"rrsets":[{"name":"mytest.example.org.","type":"A","ttl":3600,"changetype":"REPLACE","records":[{"content":"127.0.0.1","set_ptr":false,"disabled":false}]}]}' http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.org
