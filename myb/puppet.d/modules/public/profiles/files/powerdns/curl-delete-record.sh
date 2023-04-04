#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

curl -s -H "X-API-Key: ${API_KEY}" -X PATCH -d '{"rrsets":[{"name":"mytest.example.org.","type":"TXT","ttl":3600,"changetype":"DELETE","records":[{"content":"\"this is a test\"","set_ptr":false,"disabled":false}]}]}' http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.org
