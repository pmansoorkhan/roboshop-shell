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

dnf install maven -y  &>> "$LOG_FILE"
VALIDATE "$?" "INstalling Maven package"

id roboshop  &>> "$LOG_FILE"
if [ "$?" -ne 0 ]; then 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  | tee -a "$LOG_FILE"
   VALIDATE "$?" "Adding user"
else 
 echo -e "${B} User already exist ${N} .... ${Y} Skipping ${N} " 
fi


mkdir -p /app  &>> "$LOG_FILE"
VALIDATE "$?" "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip   &>> "$LOG_FILE"
VALIDATE "$?" "Downloading Shipping zip file "

cd /app 
VALIDATE "$?" "Move to app directory"

rm -rf /app/* &>> "$LOG_FILE"
VALIDATE "$?" "Removing old content from app directory"

unzip /tmp/shipping.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Unzipping shipping code"

mvn clean package &>> "$LOG_FILE"
VALIDATE "$?" "Installing MAVEN dependencies"

mv target/shipping-1.0.jar shipping.jar  &>> "$LOG_FILE" 
VALIDATE "$?" "Renaming file name"

cp "$SCRIPT_DIR/shipping.service" /etc/systemd/system/shipping.service  &>> "$LOG_FILE"

systemctl daemon-reload &>> "$LOG_FILE" 
VALIDATE "$?" "Reloading SHIPPING service"

systemctl enable shipping  &>> "$LOG_FILE"
systemctl start shipping   &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting SHIPING Service"
