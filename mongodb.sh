#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
B="\e[34m"

# Check root user
if [ "$USER_ID" -ne 0 ]; then
    echo -e "${R}Please run the script as root user${N}"
    exit 1
fi

# Create log directory
mkdir -p "$LOG_FOLDER"

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "${R}$2 .... is failed${N}" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "${G}$2 ...... is successful${N}" | tee -a "$LOG_FILE"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE "$?" "Copying mongo repo file"

dnf install mongodb-org -y &>> "$LOG_FILE" 
VALIDATE "$?" "Installing  mongodb"

systemctl enable mongod &>> "$LOG_FILE" 
VALIDATE "$?" "Enabling mongodb service"

systemctl start mongod &>> "$LOG_FILE" 
VALIDATE "$?" "Starting mongodb service"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE "$?" "Updating mongodb config file" 
 

systemctl restart mongod &>> "$LOG_FILE"
VALIDATE "$?" "Restarted mongodb service"

echo -e " ${G}MongoDB installation is completed successfully${N}" | tee -a "$LOG_FILE" 
