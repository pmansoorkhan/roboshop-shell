#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"  

mkdir -p "$LOG_FOLDER"

if [ "$USER_ID" -ne  0 ]; then 
   echo -e "${R} Please run the script with root access ${N}"
   exit 1
fi  

VALIDATE(){
 if [ "$1" -ne 0 ]; then
    echo -e "$2 is ....... ${R} failed ${N}" | tee -a "$LOG_FILE"
 else 
    echo -e "$2 is ..... ${G} successful ${N}" | tee -a "$LOG_FILE"
 fi
}

dnf module disable redis -y &>> "$LOG_FILE"
dnf module enable redis:7 -y  &>> "$LOG_FILE"
VALIDATE "$?" "Disabling and Enabling the Redis version"

dnf install redis -y  &>> "$LOG_FILE"
VALIDATE "$?" "Installing Redis"

sed -i "s/127.0.0.0/0.0.0.0/g"  -e " /protected-mode/ c protected-mode no" /etc/redis/redis.conf
VALIDATE "$?" "Changing the config"

systemctl enable redis  &>> "$LOG_FILE"
systemctl start redis
VALIDATE "$?" "Enabling & Staerted Redis"

echo -e " ${G} Redis installation is completed successfully ${N}" | tee -a "$LOG_FILE" 




