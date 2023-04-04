#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
pgm="${0##*/}" # Program basename
progdir="${0%/*}" # Program directory

. ${progdir}/config

pdnsutil list-all-zones
