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
  echo -e "${R} Please run the script with root id ${N}" | tee -a "$LOG_FILE"
  exit 1
fi
mkdir -p "$LOG_FOLDER"  &>> "$LOG_FILE"

VALIDATE() {
if [ "$1" -ne 0 ]; then 
    echo -e "$2 ..... ${R} Failed ${N}"  | tee -a "$LOG_FILE"
    exit 1
else 
  echo -e "$2 .... ${G} Successful ${N}"  | tee -a "$LOG_FILE"
fi
}

dnf module disable nodejs -y   &>> "$LOG_FILE"
dnf module enable nodejs:20 -y   &>> "$LOG_FILE"
VALIDATE "$?" "Disabling & Enabling NODEJS"

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

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Downloading user zip file "

cd /app 
VALIDATE "$?" "Move to app directory"

rm -rf /app/* &>> "$LOG_FILE"
VALIDATE "$?" "Removing old content from app directory"

unzip /tmp/user.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Unzipping user code"

npm install  &>> "$LOG_FILE"
VALIDATE "$?" "Installing NODEJS dependencies"

cp "$SCRIPT_DIR/user.service" /etc/systemd/system/user.service
VALIDATE "$?" "Copying USER service file"

systemctl daemon-reload  &>> "$LOG_FILE"
systemctl enable user    &>> "$LOG_FILE"
systemctl start user     &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting USER service"

echo -e "${G} USER installation is completed successfully ${N}" | tee -a "$LOG_FILE"