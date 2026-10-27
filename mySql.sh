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
SCRIPT_DIR=$PWD

if [ "$USER_ID" -ne 0 ]; then
  echo -e "${R} Please run the script with root id ${N}" 
  exit 1
fi

mkdir -p "$LOG_FOLDER" 
VALIDATE() {
    if [ "$1" -ne 0 ]; then 
        echo -e "$2 ..... ${R} Failed ${N}"  | tee -a "$LOG_FILE"
        exit 1
    else 
        echo -e "$2 .... ${G} Successful ${N}"  | tee -a "$LOG_FILE"
    fi
}

dnf install mysql-server  -y  &>> "$LOG_FILE"
VALIDATE "$?" "Installing MySql server"

systemctl enable mysqld &>> "$LOG_FILE" 
systemctl start mysqld  &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting MYSql service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> "$LOG_FILE"
VALIDATE "$?" "Setting Root Credentials"
