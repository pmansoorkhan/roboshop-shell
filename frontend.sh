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
SCRIPT_DIR="$PWD"

if [ "$USER_ID" -ne 0 ]; then
    echo -e "${R}Please run the script with root user${N}" | tee -a "$LOG_FILE"
    exit 1
fi
mkdir -p "$LOG_FOLDER" 

VALIDATE(){
if [ "$1" -ne 0  ]; then
    echo -e "$2 ........ is ${R}failed${N}" | tee -a "$LOG_FILE"
else 
    echo -e "$2 ..... is ${G}successful${N}" | tee -a "$LOG_FILE"
fi
}

dnf module list nginx -y &>> "$LOG_FILE"
VALIDATE "$?" "checking the list of modules"

dnf module disable nginx -y &>> "$LOG_FILE"
VALIDATE "$?" "Disabling all modules"

dnf module enable nginx:1.24 -y &>> "$LOG_FILE"
VALIDATE "$?" "Enabling the required module"

dnf install nginx -y  | tee -a "$LOG_FILE"
VALIDATE "$?" "Installing nginx"

systemctl enable nginx 
systemctl start nginx  &>>"$LOG_FILE"
VALIDATE "$?" "Enabling & Starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE "$?" "Removing the default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE "$?" "Download the frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE "$?" "Moving  and unzipping frontend code"


cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE "$?" "copying the config file to nginx location"

systemctl restart nginx
VALIDATE "$?" "Restarted nginx application"

echo -e "${G}Frontend server is ready to access via internet${N}" 


