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


dnf module disable nodejs  -y   &>> "$LOG_FILE"
VALIDATE "$?" "Disabling NODEJS"

dnf module enable nodejs:20  -y   &>> "$LOG_FILE"
VALIDATE "$?" "Enabling NODEJS"

dnf install nodejs -y  &>> "$LOG_FILE"
VALIDATE "$?" "Installing NODEJS"

id roboshop  &>> "$LOG_FILE"
if [ "$?" -ne 0 ]; then 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  | tee -a "$LOG_FILE"
   VALIDATE "$?" "Adding user"
else 
 echo -e "${B} User already exist ${N} .... ${Y} Skipping ${N} " 
fi

mkdir -p /app  &>> "$LOG_FILE"
VALIDATE "$?" "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE "$?" "Downloading CART zip file"

cd /app 
VALIDATE "$?" "Move to app directory"

rm -rf /app/* &>> "$LOG_FILE"
VALIDATE "$?" "Removing old content from app directory"

unzip /tmp/cart.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Unzipping CART code"

npm install  &>> "$LOG_FILE"
VALIDATE "$?" "Installing NODEJS dependencies"

cp "$SCRIPT_DIR/cart.service"  /etc/systemd/system/cart.service
VALIDATE "$?" "Copying CART service file"

systemctl daemon-reload
VALIDATE "$?" "Reloading CART service"

systemctl enable cart 
systemctl start cart
VALIDATE "$?" "Enabling & Starting service"


