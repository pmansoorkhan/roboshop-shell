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
mkdir -p "$LOG_FOLDER"     # Create log directory
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 .... is ${R}failed${N}" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2 ...... is ${G}successful${N}" | tee -a "$LOG_FILE"
    fi
}

dnf module list nodejs &>> "$LOG_FILE"
VALIDATE "$?" "checking nodejs module list"

dnf module  disable nodejs -y &>> "$LOG_FILE"
VALIDATE "$?" "disabling the nodejs module"

dnf module enable nodejs:20 -y &>> "$LOG_FILE"
VALIDATE "$?" "Enabling the nodejs module"

dnf install nodejs -y &>> "$LOG_FILE"
VALIDATE "$?" "nodejs installation"


id roboshop &>> "$LOG_FILE"
    if [ "$?" -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> "$LOG_FILE"
        VALIDATE "$?" "Creating system user"
    else
        echo -e "${Y}roboshop user already exists${N}....${B}Skipping user creation${N}" | tee -a "$LOG_FILE"
    fi
mkdir -p /app  &>> "$LOG_FILE"
VALIDATE "$?" "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Downloading catalogue zip file"

cd /app   # Move to app directory
unzip /tmp/catalogue.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Extracting catalogue zip file"

cd /app  
npm install  &>> "$LOG_FILE"
VALIDATE "$?" "Installing nodejs dependencies"

