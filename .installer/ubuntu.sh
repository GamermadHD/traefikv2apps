#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
appstartup() {
if [[ $EUID -ne 0 ]];then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔  You must execute as a SUDO user (with sudo) or as ROOT!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit 0
fi
while true; do
  if [[ ! -x $(command -v docker) ]];then exit;fi
  if [[ ! -x $(command -v docker-compose) ]];then exit;fi
  headinterface
done
}
headinterface() {
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  App Head Section Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    [ 1 ] Install  Apps
    [ 2 ] Remove   Apps
    [ 3 ] Backup   Apps
    [ 4 ] Restore  Apps

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit || [ help or HELP ] - Help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↘️  Type Number and Press [ENTER]: " headsection </dev/tty
  case $headsection in
    1) clear && interface ;;
    2) clear && removeapp ;;
    3) clear && backupstorage ;;
    4) clear && restorestorage ;;
    help|HELP|Help) clear && sectionhelplayout ;;
    Z|z|exit|EXIT|Exit|close) exit ;;
    *) appstartup ;;
  esac
}
interface() {
buildshow=$(ls -1p /opt/apps/ | grep '/$' | $(command -v sed) 's/\/$//')
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  App Category Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$buildshow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit || [ help or HELP ] - Help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↘️  Type Section Name and Press [ENTER]: " section </dev/tty
  if [[ $section == "exit" || $section == "Exit" || $section == "EXIT" || $section  == "z" || $section == "Z" ]];then clear && headinterface;fi
  if [[ $section == "" ]];then clear && interface;fi
  if [[ $section == "help" || $section == "HELP" ]];then clear && sectionhelplayout;fi
     checksection=$(ls -1p /opt/apps/ | grep '/$' | $(command -v sed) 's/\/$//' | grep -x $section)
  if [[ $checksection == "" ]];then clear && interface;fi
  if [[ $checksection == $section ]];then clear && install;fi
}
install() {
section=${section}
buildshow=$(ls -1p /opt/apps/${section}/compose/ | sed -e 's/.yml//g' )
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Apps to install under ${section} category
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$buildshow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit || [ help or HELP ] - Help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to install and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then clear && interface;fi
  if [[ $typed == "" ]];then clear && install;fi
  if [[ $typed == "help" || $typed == "HELP" ]];then clear && helplayout;fi
     buildapp=$(ls -1p /opt/apps/${section}/compose/ | $(command -v sed) -e 's/.yml//g' | grep -x $typed)
  if [[ $buildapp == "" ]];then clear && install;fi
  if [[ $buildapp == $typed ]];then clear && runinstall;fi
}
sectionhelplayout() {
helpshowsection=$(ls -1p /opt/apps/.help/ | sed -e 's/.me//g' )
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$helpshowsection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to show short informations and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then clear && headinterface;fi
  if [[ $typed == "" ]];then clear && helplayout;fi
     helpappsection=$(ls -1p /opt/apps/.help/ | $(command -v sed) -e 's/.me//g' | grep -x $typed)
  if [[ $helpappsection == "" ]];then clear && sectionhelplayout;fi
  if [[ $helpappsection == $typed ]];then clear && showhelpsection;fi
}
showhelpsection() {
showhelptypedsection=$(cat /opt/apps/.help/${typed}.me )
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Help for ${typed}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$showhelptypedsection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "Confirm Info | PRESS [ENTER] "  typed </dev/tty
  clear && sectionhelplayout
}
helplayout() {
section=${section}
helpshow=$(ls -1p /opt/apps/${section}/.help/ | sed -e 's/.me//g' )
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Help for ${section}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$helpshow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to get help and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then clear && interface;fi
  if [[ $typed == "" ]];then clear && helplayout;fi
     helpapp=$(ls -1p /opt/apps/${section}/.help/ | $(command -v sed) -e 's/.me//g' | grep -x $typed)
  if [[ $helpapp == "" ]];then clear && helplayout;fi
  if [[ $helpapp == $typed ]];then clear && showhelp;fi
}
showhelp() {
section=${section}
showhelptyped=$(cat /opt/apps/${section}/.help/${typed}.me )
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Help for ${typed}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$showhelptyped

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "Confirm Info | PRESS [ENTER] " typed </dev/tty
  clear && helplayout
}
### backup docker ###
backupstorage() {
storagefolder=$(ls -1p /mnt/unionfs/appbackups/ | grep '/$' | $(command -v sed) 's/\/$//')
if [[ $storagefolder == "" ]];then 
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Backup folder
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 You need to set a backup folder
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type Name to set the Backup-Folder and Press [ENTER]: " storage </dev/tty
  if [[ $storage == "exit" || $storage == "Exit" || $storage == "EXIT" || $storage  == "z" || $storage == "Z" ]];then clear && interface;fi
  if [[ $storage == "" ]];then clear && backupstorage;fi
  if [[ $storage != "" ]];then $(command -v mkdir) -p /mnt/unionfs/appbackups/${storage};fi
     teststorage=$(ls -1p /mnt/unionfs/appbackups/ | grep '/$' | $(command -v sed) 's/\/$//' | grep -x $storage)
  if [[ $teststorage == $storage ]];then backupdocker;fi
else
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Backup folder
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$storagefolder

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type Name to set the Backup-Folder and Press [ENTER]: " storage </dev/tty
  if [[ $storage == "exit" || $storage == "Exit" || $storage == "EXIT" || $storage  == "z" || $storage == "Z" ]];then clear && interface;fi
  if [[ $storage == "" ]];then clear && backupstorage;fi
     teststorage=$(ls -1p /mnt/unionfs/appbackups/ | grep '/$' | $(command -v sed) 's/\/$//' | grep -x $storage)
  if [[ $teststorage == $storage ]];then backupdocker;fi
  if [[ $storage != "" ]];then 
     $(command -v mkdir) -p /mnt/unionfs/appbackups/${storage}
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  New Backup folder set to $storage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 3
backupdocker
  fi
fi
}
backupdocker() {
storage=${storage}
rundockers=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -v 'trae' | grep -v 'auth')
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Backup running Dockers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$rundockers

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   [ all = Backup all running Container ]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to Backup and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then clear && interface;fi
  if [[ $typed == "" ]];then clear && backupdocker;fi
  if [[ $typed == "help" || $typed == "HELP" ]];then clear && helplayout;fi
  if [[ $typed == "all" || $typed == "All" || $typed == "ALL" ]];then clear && backupall;fi
     builddockers=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -x $typed)
  if [[ $builddockers == "" ]];then clear && backupdocker;fi
  if [[ $builddockers == $typed ]];then clear && runbackup;fi
}
backupall() {
storage=${storage}
$(command -v docker) system prune -af 1>/dev/null 2>&1
$(command -v docker) pull ghcr.io/doob187/docker-remote:latest 1>/dev/null 2>&1
dockers=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -v 'trae' | grep -v 'auth')
for i in ${dockers};do
   echo "Backup-tar.gz for $i is running" && $(command -v docker) run --rm -v /opt/appdata:/backup/$i -v /mnt:/mnt ghcr.io/doob187/docker-remote:latest backup $i ${storage} 1>/dev/null 2>&1
done
$(command -v docker) system prune -af 1>/dev/null 2>&1
clear && backupdocker
}
runbackup() {
updatecompose
storage=${storage}
typed=${typed}
basefolder="/opt/appdata"
if [[ -d $basefolder/${typed} ]];then
   $(command -v docker) system prune -af 1>/dev/null 2>&1
   $(command -v docker) pull ghcr.io/doob187/docker-remote:latest 1>/dev/null 2>&1
   $(command -v docker) run --rm -v /opt/appdata:/backup/${typed} -v /mnt:/mnt ghcr.io/doob187/docker-remote:latest backup ${typed} ${storage}
   $(command -v find) $basefolder/${typed} -exec $(command -v chown) -hR 1000:1000 {} \;
   $(command -v docker) system prune -af 1>/dev/null 2>&1
   clear && backupdocker
else
   clear && backupdocker
fi
}
### restore backup ###
restorestorage() {
storage=$(ls -1p /mnt/unionfs/appbackups/ | grep '/$' | $(command -v sed) 's/\/$//')
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Restore folder
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$storage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type Name to set the Backup-Folder and Press [ENTER]: " storage </dev/tty
  if [[ $storage == "exit" || $storage == "Exit" || $storage == "EXIT" || $storage  == "z" || $storage == "Z" ]];then clear && interface;fi
  if [[ $storage == "" ]];then clear && backupstorage;fi
     teststorage=$(ls -1p /mnt/unionfs/appbackups/ | grep '/$' | $(command -v sed) 's/\/$//' | grep -x $storage)
  if [[ $teststorage == $storage ]];then clear && restoredocker;fi
}
restoredocker() {
storage=${storage}
runrestore=$(ls -1p /mnt/unionfs/appbackups/${storage} | $(command -v sed) -e 's/.tar.gz//g' | grep -v 'trae' | grep -v 'auth')
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  Restore Dockers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$runrestore

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to Restore and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then clear && interface;fi
  if [[ $typed == "" ]];then clear && restoredocker;fi
  if [[ $typed == "help" || $typed == "HELP" ]];then clear && helplayout;fi
  if [[ $typed == "all" || $typed == "All" || $typed == "ALL" ]];then clear && restoreall;fi
     builddockers=$(ls -1p /mnt/unionfs/appbackups/${storage} | $(command -v sed) -e 's/.tar.gz//g' | grep -x $typed)
  if [[ $builddockers == "" ]];then clear && restoredocker;fi
  if [[ $builddockers == $typed ]];then clear && runrestore;fi
}
restoreall() {
storage=${storage}
apps=$(ls -1p /mnt/unionfs/appbackups/${storage} | $(command -v sed) -e 's/.tar.gz//g' | grep -v 'trae' | grep -v 'auth')
for i in ${apps};do
   updatecompose
   basefolder="/opt/appdata"
   if [[ ! -d $basefolder/$i ]];then
      echo "Create folder for $i is running"  
      folder=$basefolder/$i
      for ii in ${folder}; do
          $(command -v mkdir) -p $ii
          $(command -v find) $ii -exec $(command -v chmod) a=rx,u+w {} \;
          $(command -v find) $ii -exec $(command -v chown) -hR 1000:1000 {} \;
      done
   fi
   $(command -v docker) system prune -af 1>/dev/null 2>&1
   $(command -v docker) pull ghcr.io/doob187/docker-remote:latest 1>/dev/null 2>&1
   echo "Restore for $i is running" && $(command -v docker) run --rm -v /opt/appdata:/restore -v /mnt:/mnt ghcr.io/doob187/docker-remote:latest restore $i ${storage}
done
clear && restoreall
}
runrestore() {
updatecompose
typed=${typed}
storage=${storage}
basefolder="/opt/appdata"
compose="compose/docker-compose.yml"
if [[ ! -d $basefolder/${typed} ]];then
   folder=$basefolder/${typed}
   for i in ${folder}; do
       $(command -v mkdir) -p $i
       $(command -v find) $i -exec $(command -v chmod) a=rx,u+w {} \;
       $(command -v find) $i -exec $(command -v chown) -hR 1000:1000 {} \;
   done
fi
builddockers=$(ls -1p /mnt/unionfs/appbackups/${storage} | $(command -v sed) -e 's/.tar.gz//g' | grep -x $typed)
if [[ $builddockers == $typed ]];then
   $(command -v docker) system prune -af 1>/dev/null 2>&1
   $(command -v docker) pull ghcr.io/doob187/docker-remote:latest 1>/dev/null 2>&1
   echo "Restore for ${typed} is running" && $(command -v docker) run --rm -v /opt/appdata:/restore -v /mnt:/mnt ghcr.io/doob187/docker-remote:latest restore ${typed} ${storage}
   appfolder=/opt/apps
   HEADSECTION=${HEADSECTION:-/}
   IGNORE="! -path '**.subactions/**'"
   mapfile -t files < <(eval find ${appfolder} -type f -name $typed.yml ${IGNORE})
   for i in "${files[@]}"; do
       section=$(dirname "${i}" | sed "s#${appfolder}${HEADSECTION}##g" | sed 's/[[:alnum:]]*$//' | sed 's|[/y]||g' )
   done
   section=${section}
   typed=${typed}
   runinstall
else
   clear && restoredocker
fi
}
runinstall() {
  section=${section}
  typed=${typed}
  updatecompose
  compose="compose/docker-compose.yml"
  composeoverwrite="compose/docker-compose.override.yml"
  storage="/mnt/downloads"
  appfolder="/opt/apps"
  basefolder="/opt/appdata"
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Please Wait,
    We are installing ${typed} for you
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  if [[ ! -d $basefolder/compose/ ]];then $(command -v mkdir) -p $basefolder/compose/;fi
  if [[ ! -x $(command -v rsync) ]];then $(command -v apt) install rsync -yqq >/dev/null 2>&1;fi
  if [[ -f $basefolder/$compose ]];then $(command -v rm) -rf $basefolder/$compose;fi
  if [[ -f $basefolder/$composeoverwrite ]];then $(command -v rm) -rf $basefolder/$composeoverwrite;fi
  if [[ ! -f $basefolder/$compose ]];then $(command -v rsync) $appfolder/${section}/compose/${typed}.yml $basefolder/$compose -aq --info=progress2 -hv;fi
  if [[ ! -x $(command -v lshw) ]];then $(command -v apt) install lshw -yqq >/dev/null 2>&1;fi
  if [[ ${section} == "mediaserver" || ${section} == "encoder" ]];then
     gpu="Intel NVIDIA"
     for i in ${gpu};do
        TDV=$(lspci | grep -i --color 'vga\|3d\|2d' | grep -E $i 1>/dev/null 2>&1 && echo true || echo false)
        if [[ $TDV == "true" ]];then $(command -v rsync) $appfolder/${section}/compose/gpu/$i.yml $basefolder/$composeoverwrite -aq --info=progress2 -hv;fi
     done
     if [[ -f $basefolder/$composeoverwrite ]];then
        if [[ $(uname) == "Darwin" ]];then
           $(command -v sed) -i '' "s/<APP>/${typed}/g" $basefolder/$composeoverwrite
        else
           $(command -v sed) -i "s/<APP>/${typed}/g" $basefolder/$composeoverwrite
        fi
     fi
  fi
  if [[ -f $appfolder/${section}/compose/.overwrite/${typed}.overwrite.yml ]];then $(command -v rsync) $appfolder/${section}/compose/.overwrite/${typed}.overwrite.yml $basefolder/$composeoverwrite -aq --info=progress2 -hv;fi
  if [[ ! -d $basefolder/${typed} ]];then
     folder=$basefolder/${typed}
     for i in ${folder}; do
         $(command -v mkdir) -p $i
         $(command -v find) $i -exec $(command -v chmod) a=rx,u+w {} \;
         $(command -v find) $i -exec $(command -v chown) -hR 1000:1000 {} \;
     done
  fi
  container=$($(command -v docker) ps -aq --format '{{.Names}}' | grep -x ${typed})
  if [[ $container == ${typed} ]];then
     docker="stop rm"
     for i in ${docker}; do
         $(command -v docker) $i ${typed} 1>/dev/null 2>&1
     done
     $(command -v docker) image prune -af 1>/dev/null 2>&1
  else
     $(command -v docker) image prune -af 1>/dev/null 2>&1
  fi
  if [[ ${section} == "addons" && ${typed} == "vnstat" ]];then vnstatcheck;fi
  if [[ ${section} == "addons" && ${typed} == "autoscan" ]];then autoscancheck;fi
  if [[ ${section} == "mediaserver" && ${typed} == "plex" ]];then plexclaim;fi
  if [[ ${section} == "downloadclients" && ${typed} == "jdownloader2" ]];then
     folder=$storage/${typed}
     for i in ${folder}; do
         $(command -v mkdir) -p $i
         $(command -v find) $i -exec $(command -v chmod) a=rx,u+w {} \;
         $(command -v find) $i -exec $(command -v chown) -hR 1000:1000 {} \;
     done
  fi
  if [[ ${section} == "mediamanager" && ${typed} == "readarr" ]];then
     folder=$storage/books
     for i in ${folder}; do
         $(command -v mkdir) -p $i
         $(command -v find) $i -exec $(command -v chmod) a=rx,u+w {} \;
         $(command -v find) $i -exec $(command -v chown) -hR 1000:1000 {} \;
     done
  fi
  if [[ ${section} == "system" && ${typed} == "mount" ]];then
     checkmnt=$($(command -v mountpoint) -q /mnt/unionfs && echo true || echo false)
     mount=$($(command -v docker) ps -aq --format={{.Names}} | grep -x 'mount')
     if [[ ${checkmnt} == "true" && ${mount} == "mount" ]];then $(command -v docker) stop mount 1>/dev/null 2>&1 && $(command -v fusermount) -uzq /mnt/unionfs 1>/dev/null 2>&1;fi
     if [[ ${checkmnt} == "false" && ${mount} == "mount" ]];then $(command -v docker) stop mount 1>/dev/null 2>&1 && $(command -v fusermount) -uzq /mnt/unionfs 1>/dev/null 2>&1;fi
     if [[ ${checkmnt} == "false" && ${mount} == "" ]];then $(command -v fusermount) -uzq /mnt/unionfs 1>/dev/null 2>&1;fi
  fi
  if [[ ${section} == "downloadclients" && ${typed} == "youtubedl-material" ]];then
     folder="appdata audio video subscriptions"
     for i in ${folder}; do
         $(command -v mkdir) -p $basefolder/${typed}/$i
         $(command -v find) $basefolder/${typed}/$i -exec $(command -v chmod) a=rx,u+w {} \;
         $(command -v find) $basefolder/${typed}/$i -exec $(command -v chown) -hR 1000:1000 {} \;
     done
     folder=$storage/youtubedl
     for i in ${folder}; do
         $(command -v mkdir) -p $i
         $(command -v find) $i -exec $(command -v chmod) a=rx,u+w {} \;
         $(command -v find) $i -exec $(command -v chown) -hR 1000:1000 {} \;
     done
  fi
  if [[ ${typed} == "bitwarden" ]];then
     if [[ -f $appfolder/.subactions/compose/${typed}.sh ]];then $(command -v bash) $appfolder/.subactions/compose/${typed}.sh;fi
  fi
  if [[ -f $basefolder/$compose ]];then
     $(command -v cd) $basefolder/compose/
     $(command -v docker-compose) config 1>/dev/null 2>&1
     errorcode=$?
     if [[ $errorcode -ne 0 ]];then
  tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ❌ ERROR
    Compose check of ${typed} has failed
    Return code is ${errorcode}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "Confirm Info | PRESS [ENTER]" typed </dev/tty
  clear && interface
     else
       composer=$(command -v docker-compose)
       for i in ${composer};do
          $i pull ${typed} 1>/dev/null 2>&1
		  $i up -d --force-recreate 1>/dev/null 2>&1
          $(command -v chown) -cR 1000:1000 $basefolder/${typed} 1>/dev/null 2>&1
          $i restart 1>/dev/null 2>&1
       done
     fi
  fi
  if [[ ${section} == "mediaserver" ]];then subtasks;fi
  if [[ ${section} == "downloadclients" ]];then subtasks;fi
  if [[ ${typed} == "overseerr" ]];then overserrf2ban;fi
  if [[ ${typed} == "overseerr" || ${typed} == "petio" || ${typed} == "heimdall" || ${typed} == "librespeed" || ${typed} == "tautulli" ]];then subtasks;fi
     $($(command -v docker) ps -aq --format '{{.Names}}{{.State}}' | grep -qE ${typed}running 1>/dev/null 2>&1)
     errorcode=$?
  if [[ $errorcode -eq 0 ]];then
  source $basefolder/compose/.env
  tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ${typed} has successfully deployed and is now working
    https://${typed}.${DOMAIN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  sleep 10
  clear
fi
if [[ -f $basefolder/$compose ]];then $(command -v rm) -rf $basefolder/$compose;fi
if [[ -f $basefolder/$composeoverwrite ]];then $(command -v rm) -rf $basefolder/$composeoverwrite;fi
clear && install
}
overserrf2ban() {
OV2BAN="/etc/fail2ban/filter.d/overseerr.local"
if [[ ! -f $OV2BAN ]];then
cat << EOF | tee -a $OV2BAN
[Definition]
failregex = .*\[info\]\[Auth\]\: Failed sign-in attempt.*"ip":"<HOST>"
EOF
fi
f2ban=$($(command -v systemctl) is-active fail2ban | grep -qE 'active' && echo true || echo false)
if [[ $f2ban != "false" ]];then $(command -v systemctl) reload-or-restart fail2ban.service 1>/dev/null 2>&1;fi
}
vnstatcheck() {
  if [[ ! -x $(command -v vnstat) ]];then $(command -v apt) install vnstat -yqq;fi
}
autoscancheck() {
$(docker ps -aq --format={{.Names}} | grep -E 'arr|ple|emb|jelly' 1>/dev/null 2>&1)
code=$?
if [[ $code -eq 0 ]];then
   $(command -v rsync) $appfolder/.subactions/compose/${typed}.config.yml $basefolder/${typed}/config.yml -aq --info=progress2 -hv
   $(command -v bash) $appfolder/.subactions/compose/${typed}.sh
fi
}
plexclaim() {
compose="compose/docker-compose.yml"
basefolder="/opt/appdata"
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀  PLEX CLAIM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Please claim your Plex server
    https://www.plex.tv/claim/
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "Enter your PLEX CLAIM CODE : " PLEXCLAIM
  if [[ $PLEXCLAIM != "" ]];then
     if [[ $(uname) == "Darwin" ]];then
        $(command -v sed) -i '' "s/PLEX_CLAIM_ID/$PLEXCLAIM/g" $basefolder/$compose
     else
        $(command -v sed) -i "s/PLEX_CLAIM_ID/$PLEXCLAIM/g" $basefolder/$compose
     fi
  else
     echo "Plex Claim cannot be empty"
     plexclaim
  fi
}
subtasks() {
typed=${typed}
section=${section}
basefolder="/opt/appdata"
appfolder="/opt/apps"
source $basefolder/compose/.env
authcheck=$($(command -v docker) ps -aq --format '{{.Names}}' | grep -x 'authelia' 1>/dev/null 2>&1 && echo true || echo false)
conf=$basefolder/authelia/configuration.yml
confnew=$basefolder/authelia/.new-configuration.yml.new
confbackup=$basefolder/authelia/.backup-configuration.yml.backup
authadd=$(cat $conf | grep -E ${typed})
  if [[ ! -x $(command -v ansible) || ! -x $(command -v ansible-playbook) ]];then $(command -v apt) ansible --reinstall -yqq;fi
  if [[ -f $appfolder/.subactions/compose/${typed}.yml ]];then $(command -v ansible-playbook) $appfolder/.subactions/compose/${typed}.yml;fi
     $(grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | head -n1 |grep -qE 'i7|i9' 1>/dev/null 2>&1)
     setcode=$?
     if [[ $setcode -eq 0 ]];then
        if [[ -f $appfolder/.subactions/compose/${typed}.sh ]];then $(command -v bash) $appfolder/.subactions/compose/${typed}.sh;fi
     fi
  if [[ $authadd == "" ]];then
     if [[ ${section} == "mediaserver" || ${section} == "request" || ${typed} == "librespeed" || ${typed} == "xteve" ]];then
     { head -n 38 $conf;
     echo "\
    - domain: ${typed}.${DOMAIN}
      policy: bypass"; tail -n +39 $conf; } > $confnew
        if [[ -f $conf ]];then $(command -v rsync) $conf $confbackup -aq --info=progress2 -hv;fi
        if [[ -f $conf ]];then $(command -v rsync) $confnew $conf -aq --info=progress2 -hv;fi
        if [[ $authcheck == "true" ]];then $(command -v docker) restart authelia 1>/dev/null 2>&1;fi
        if [[ -f $conf ]];then $(command -v rm) -rf $confnew;fi
     fi
  fi
  if [[ ${section} == "mediaserver" || ${section} == "request" || ${section} == "downloadclients" ]];then $(command -v docker) restart ${typed} 1>/dev/null 2>&1;fi
}
removeapp() {
list=$($(command -v docker) ps -aq --format '{{.Names}}' | grep -vE 'auth|trae|cf-companion')
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🚀   App Removal Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$list
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    [ EXIT or Z ] - Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -erp "↪️ Type App-Name to remove and Press [ENTER]: " typed </dev/tty
  if [[ $typed == "exit" || $typed == "Exit" || $typed == "EXIT" || $typed  == "z" || $typed == "Z" ]];then interface;fi
  if [[ $typed == "" ]];then clear && removeapp;fi
     checktyped=$($(command -v docker) ps -aq --format={{.Names}} | grep -x $typed)
  if [[ $checktyped == $typed ]];then clear && deleteapp;fi
}
deleteapp() {
  typed=${typed}
  basefolder="/opt/appdata"
  storage="/mnt/downloads"
  source $basefolder/compose/.env
  conf=$basefolder/authelia/configuration.yml
  checktyped=$($(command -v docker) ps -aq --format={{.Names}} | grep -x $typed)
  auth=$(cat -An $conf | grep -x ${typed}.${DOMAIN} | awk '{print $1}')
  if [[ $checktyped == $typed ]];then
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ${typed} removal started    
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
     app=${typed}
     for i in ${app}; do
         $(command -v docker) stop $i 1>/dev/null 2>&1
         $(command -v docker) rm $i 1>/dev/null 2>&1
         $(command -v docker) image prune -af 1>/dev/null 2>&1
     done
     if [[ -d $basefolder/${typed} ]];then 
        folder=$basefolder/${typed}
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   App ${typed} folder removal started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
        for i in ${folder}; do
            $(command -v rm) -rf $i 1>/dev/null 2>&1
        done
     fi
     if [[ -d $storage/${typed} ]];then 
        folder=$storage/${typed}
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Storage ${typed} folder removal started
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
        for i in ${folder}; do
            $(command -v rm) -rf $i 1>/dev/null 2>&1
        done
     fi
     if [[ $auth == ${typed} ]];then
        if [[ ! -x $(command -v bc) ]];then $(command -v apt) install bc -yqq 1>/dev/null 2>&1;fi
           source $basefolder/compose/.env
           authrmapp=$(cat -An $conf | grep -x ${typed}.${DOMAIN})
           authrmapp2=$(echo "$(${authrmapp} + 1)" | bc)
        if [[ $authrmapp != "" ]];then sed -i '${authrmapp};${authrmapp2}d' $conf;fi
           $($(command -v docker) ps -aq --format '{{.Names}}' | grep -x authelia 1>/dev/null 2>&1)
           newcode=$?
        if [[ $newcode -eq 0 ]];then $(command -v docker) restart authelia;fi
     fi
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ${typed} removal finished
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 2 && removeapp
  else
     removeapp
  fi
}
updatecompose() {
## existing 
if [[ -x $(command -v docker-compose) ]];then 
   COMPOSE_VERSION=$($(command -v curl) --silent -fsSL https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
   INSTALLED_COMPOSE=$( (docker-compose --version 2> /dev/null || echo "0") | sed -E 's/(\S+ )(version )?([0-9][a-zA-Z0-9_.-]*)(, build .*)?/\3/')
   if [[ ${INSTALLED_COMPOSE} != ${COMPOSE_VERSION} ]];then
      sh -c "curl --silent -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
      sh -c "curl --silent -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
      if [[ ! -L "/usr/bin/docker-compose" ]];then $(command -v rm) -f /usr/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose;fi
      $(command -v chmod) a=rx,u+w /usr/local/bin/docker-compose >/dev/null 2>&1 
      $(command -v chmod) a=rx,u+w /usr/bin/docker-compose >/dev/null 2>&1
   fi
fi
## not exist
if [[ ! -x $(command -v docker-compose) ]];then 
   COMPOSE_VERSION=$($(command -v curl) --silent -fsSL https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
   sh -c "curl --silent -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
   sh -c "curl --silent -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
   if [[ ! -L "/usr/bin/docker-compose" ]];then $(command -v rm) -f /usr/bin/docker-compose && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose;fi
   $(command -v chmod) a=rx,u+w /usr/local/bin/docker-compose >/dev/null 2>&1 
   $(command -v chmod) a=rx,u+w /usr/bin/docker-compose >/dev/null 2>&1
fi
}
##########
appstartup
