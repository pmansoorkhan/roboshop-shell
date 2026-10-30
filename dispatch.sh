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

dnf install golang -y   &>> "$LOG_FILE"
VALIDATE "$?" "Installing GOlang"

id roboshop  &>> "$LOG_FILE"
if [ "$?" -ne 0 ]; then 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  | tee -a "$LOG_FILE"
   VALIDATE "$?" "Adding user"
else 
 echo -e "${B} User already exist ${N} .... ${Y} Skipping ${N} " 
fi

mkdir -p /app  &>> "$LOG_FILE"
VALIDATE "$?" "Creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Downloading Dispatch zip file "

cd /app 
VALIDATE "$?" "Move to app directory"

rm -rf /app/* &>> "$LOG_FILE"
VALIDATE "$?" "Removing old content from app directory"

unzip /tmp/dispatch.zip   &>> "$LOG_FILE"
VALIDATE "$?" "Unzipping Dispatch code"
#cd /app
go mod init dispatch &>> "$LOG_FILE"
VALIDATE "$?" "Iniatiating  Dispatch"

go get   &>> "$LOG_FILE"
go build  &>> "$LOG_FILE"
VALIDATE "$?" "Get & Building code"

cp "$SCRIPT_DIR/dispatch.service" /etc/systemd/system/dispatch.service
VALIDATE "$?" "Copying Dispatch service file"

systemctl daemon-reload  &>> "$LOG_FILE"
VALIDATE "$?" "Reloading Dispatch service"

systemctl enable dispatch &>> "$LOG_FILE"
systemctl start dispatch
VALIDATE "$?" "Enabling & Starting Dispatch service"


