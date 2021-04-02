#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
basefolder="/opt/appdata"
typed=autoscan
composeoverwrite="compose/docker-compose.override.yml"
anchor() {
if [[ ! -x $(command -v rclone) ]];then curl https://rclone.org/install.sh | sudo bash >/dev/null 2>&1;fi
echo "\

anchors:" >> $basefolder/${typed}/config.yml
IFS=$'\n'
filter="$1"
mountd=$(docker ps -aq --format={{.Names}} | grep -E "mount" && echo true || echo false)
if [[ $mountd == "false" ]]; then
   config=$basefolder/plexguide/rclone.conf
else
   config=$basefolder/mount/rclone/rclone-docker.conf
fi
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/union/d' | sed '/GDSA/d' | sort -r)
##### RUN MOUNT #####
for i in ${mounts[@]}; do
  rclone mkdir $i:/.anchors --config=${config}
  rclone touch $i:/.anchors/$i.anchor --config=${config}
echo "\
  - /mnt/unionfs/.anchors/$i.anchor" >> $basefolder/${typed}/config.yml
done
}
arrs() {
echo "\

triggers:
  manual:
    priority: 0" >> $basefolder/${typed}/config.yml
radarr=$(docker ps -aq --format={{.Names}} | grep -E 'radarr' 1>/dev/null 2>&1 && echo true || echo false)
rrun=$(docker ps -aq --format={{.Names}} | grep 'rada')
if [[ $radarr == "true" ]];then
echo "\
  radarr:" >> $basefolder/${typed}/config.yml
   for i in ${rrun};do
echo "\
    - name: $i
      priority: 2" >> $basefolder/${typed}/config.yml
   done
fi
sonarr=$(docker ps -aq --format={{.Names}} | grep -E 'sonarr' 1>/dev/null 2>&1 && echo true || echo false)
srun=$(docker ps -aq --format={{.Names}} | grep -E 'sonarr')
if [[ $sonarr == "true" ]];then
echo "\
  sonarr:" >> $basefolder/${typed}/config.yml
   for i in ${srun};do
echo "\
    - name: $i
      priority: 2" >> $basefolder/${typed}/config.yml
   done
fi
lidarr=$(docker ps -aq --format={{.Names}} | grep -E 'lidarr' 1>/dev/null 2>&1 && echo true || echo false)
lrun=$(docker ps -aq --format={{.Names}} | grep 'lidarr')
if [[ $lidarr == "true" ]];then
echo "\
  lidarr:" >> $basefolder/${typed}/config.yml

   for i in ${lrun};do
echo "\
    - name: $i
      priority: 2" >> $basefolder/${typed}/config.yml
   done
fi
}
targets() {
## inotify adding for the /mnt/unionfs
echo -n "\
  inotify:
    - priority: 1
      include:
        - ^/mnt/unionfs/
      exclude:
        - '\.(srt|pdf)$'
      paths:
      - path: /mnt/unionfs/

  targets:" >> $basefolder/${typed}/config.yml
plex=$(docker ps -aq --format={{.Names}} | grep -E 'plex' 1>/dev/null 2>&1 && echo true || echo false)
prun=$(docker ps -aq --format={{.Names}} | grep 'plex')
token=$(cat "/opt/appdata/plex/database/Library/Application Support/Plex Media Server/Preferences.xml" | sed -e 's;^.* PlexOnlineToken=";;' | sed -e 's;".*$;;' | tail -1)
if [[ $token == "" ]];then
   token=youneedtoreplacethemselfnow
fi
if [[ $plex == "true" ]];then
   for i in ${prun};do
echo "\
  $i:
    - url: http://$i:32400
      token: $token" >> $basefolder/${typed}/config.yml
   done
fi

emby=$(docker ps -aq --format={{.Names}} | grep -E 'emby' 1>/dev/null 2>&1 && echo true || echo false)
erun=$(docker ps -aq --format={{.Names}} | grep 'emby')
token=youneedtoreplacethemselfnow
if [[ $emby == "true" ]];then
   for i in ${erun};do
echo "\
  $i:
    - url: http://$i:8096
      token: $token" >> $basefolder/${typed}/config.yml
   done
fi
jelly=$(docker ps -aq --format={{.Names}} | grep -E 'jelly' 1>/dev/null 2>&1 && echo true || echo false)
jrun=$(docker ps -aq --format={{.Names}} | grep 'jelly')
token=youneedtoreplacethemselfnow
if [[ $jelly == "true" ]];then
   for i in ${jrun};do
echo "\
  $i:
    - url: http://$i:8096
      token: $token" >> $basefolder/${typed}/config.yml
   done
fi
}
addauthuser() {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     🚀 autoscan Username
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
   read -erp "Enter a username for autoscan?: " USERAUTOSCAN
if [[ $USERAUTOSCAN != "" ]]; then
   if [[ $(uname) == "Darwin" ]]; then
      sed -i '' "s/<USERNAME>/$USERAUTOSCAN/g" $basefolder/${typed}/config.yml
   else
      sed -i "s/<USERNAME>/$USERAUTOSCAN/g" $basefolder/${typed}/config.yml
   fi
else
  echo "Username for autoscan cannot be empty"
  addauthuser
fi
}
addauthpassword() {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     🚀 autoscan Password
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
   read -erp "Enter a password for $USERAUTOSCAN: " PASSWORD

if [[ $PASSWORD != "" ]]; then
   if [[ $(uname) == "Darwin" ]]; then
      sed -i '' "s/<PASSWORD>/$PASSWORD/g" $basefolder/${typed}/config.yml
   else
      sed -i "s/<PASSWORD>/$PASSWORD/g" $basefolder/${typed}/config.yml
   fi
else
  echo "Password for autoscan cannot be empty"
  addauthpassword
fi
}
runautoscan() {
    $($(command -v docker) ps -aq --format={{.Names}} | grep -E 'arr|ple|emb|jelly' 1>/dev/null 2>&1)
    errorcode=$?
if [[ $errorcode -eq 0 ]]; then
   anchor && arrs && targets && addauthuser && addauthpassword
else
     app=${typed}
     for i in ${app}; do
         $(command -v docker) stop $i 1>/dev/null 2>&1
         $(command -v docker) rm $i 1>/dev/null 2>&1
         $(command -v docker) image prune -af 1>/dev/null 2>&1
     done
     if [[ -d $basefolder/${typed} ]];then 
        folder=$basefolder/${typed}
        for i in ${folder}; do
            $(command -v rm) -rf $i 1>/dev/null 2>&1
        done
     fi
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Sorry we cannot find any running Arrs , Plex , Emby or Jellyfin 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
fi
}
runautoscan
