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
START_TIME="$(date +%s)"
mkdir -p "$LOG_FOLDER"     # Create log directory
echo "$(date "+%Y-%m-%d %H:%M:%S")  | Script started executing at:$(date)"  | tee -a "$LOG_FILE" 

if [ "$USER_ID" -ne 0 ]; then
    echo -e " $(date "+%Y-%m-%d %H:%M:%S")  | ${R} Please run the script as root user ${N}"
    exit 1
fi

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H:%M:%S")  | $2 .... ${R} failed ${N}" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H:%M:%S")  | $2 ...... ${G} successful ${N}" | tee -a "$LOG_FILE"
    fi
}

dnf module list nginx -y &>> "$LOG_FILE"
VALIDATE "$?" "checking the list of modules"

dnf module disable nginx -y &>> "$LOG_FILE"
VALIDATE "$?" "Disabling all modules"

dnf module enable nginx:1.24 -y &>> "$LOG_FILE"
VALIDATE "$?" "Enabling the required module"

dnf install nginx -y  &>> "$LOG_FILE"
VALIDATE "$?" "Installing nginx"

systemctl enable nginx  &>> "$LOG_FILE"
systemctl start nginx  &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> "$LOG_FILE"
VALIDATE "$?" "Downloading Frontend zip file"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip  &>> "$LOG_FILE"
VALIDATE $? "Downloading  and unzipping frontend"

rm -rf /etc/nginx/nginx.conf  &>> "$LOG_FILE"
VALIDATE $? "Remove default content"

cp "$SCRIPT_DIR/nginx.conf"  /etc/nginx/nginx.conf  &>> "$LOG_FILE"
VALIDATE $? "Copying  our nginx conf file"

systemctl restart nginx &>> "$LOG_FILE"
VALIDATE $? "Restarted Nginx"

print_total_time(){
    END_TIME="$(date +%s)"
    TOTAL_TIME=$(( "$END_TIME" - "$START_TIME" ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S")  | Script executed in :"${G} $TOTAL_TIME" seconds ${N}"  | tee -a "$LOG_FILE"
}

print_total_time