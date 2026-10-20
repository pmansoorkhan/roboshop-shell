#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/$LOG_FOLDER/$SCRIPT_NAME.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

if [ "$USER_ID" -ne 0 ]; then
    echo -e "${R}Please run the script with root user${N}"
    exit 1
fi
mkdir -p "$LOG_FOLDER" 

VALIDATE(){
if [ "$1" -ne 0  ]; then
    echo -e "$2 ........ is ${R}failed${N}"
else 
    echo -e "$2 ..... is ${G}successful${N}"
fi
}

dnf module list nginx -y
VALIDATE "$?" "checking the list of modules"

dnf module disable nginx -y
VALIDATE "$?" "Disabling all modules"

dnf module enable nginx:1.24 -y
VALIDATE "$?" "Enabling the required module"

dnf install nginx -y
VALIDATE "$?" "Installing nginx"

systemctl enable nginx 
systemctl start nginx
VALIDATE "$?" "Enabling & Starting nginx"

