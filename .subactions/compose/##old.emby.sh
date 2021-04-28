#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# inspiration from zendrive-local-scripts
# inspiration from Cloudbox Community
####################################
# Emby
embydb="/opt/appdata/emby/data/library.db"
embydocker"emby"
emby=$($(command -v docker) ps -aq --format {{.Names}} | grep -qE 'emby' && echo true || echo false)
if [[ ! -x $(command -v sqlite3) ]]; then apt install sqlite3 -yqq 1>/dev/null 2>&1; fi
if [[ $emby == "true" ]]; then
    $(command -v docker) stop "${embydocker}"
    $(command -v sqlite3) "$embydb" "pragma page_size=32768; vacuum;"
    $(command -v sqlite3) "$embydb" "pragma default_cache_size=60000"
    chown 1000:1000 "$embydb"
    $(command -v docker) start "${embydocker}"
fi
#EOF