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
SCRIPT_DIR="$PWD"
MONGODB_HOST="mongodb.shannu.online"

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

cd /app 
VALIDATE "$?" "Moving to app directory"

rm -rf /app/* &>> "$LOG_FILE"
VALIDATE "$?" "Removing old content from app directory"

unzip /tmp/catalogue.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Extracting catalogue zip file"

# cd /app  
# VALIDATE "$?" "Moving back to app directory"

npm install  &>> "$LOG_FILE"
VALIDATE "$?" "Installing nodejs dependencies"

cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> "$LOG_FILE"
VALIDATE "$?" "copying catalogue service file"

systemctl daemon-reload &>> "$LOG_FILE"
VALIDATE "$?" "Reloading systemd daemon service"

systemctl enable catalogue  &>> "$LOG_FILE"
VALIDATE "$?" "Enabling catalogue service"

systemctl start catalogue &>> "$LOG_FILE"
VALIDATE "$?" "Starting catalogue service"

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
VALIDATE "$?" "copying mongo repo file"

dnf install mongodb-mongosh -y &>> "$LOG_FILE"
VALIDATE "$?" "Installing mongodb shell"

INDEX=$(mongosh --host "$MONGODB_HOST" --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')  | tee -a "$LOG_FILE"
if [ "$INDEX" -le  0 ]; then 
    mongosh --host MONGODB_HOST </app/db/master-data.js &>> "$LOG_FILE"
    VALIDATE "$?" "Loading catalogue products data into MongoDB"
else
 echo -e "${G}catalogue products already loaded${N}....${Y}Skipping${N}"  
fi

# if [ -z "$INDEX" ]; then
#     echo -e  "${B}INDEX is empty. MongoDB check failed${N}"
# elif [ "$INDEX" -le 0 ]; then
#     echo  -e "${Y}Loading catalogue data${N}"
# else
#     echo -e "${G}Catalogue products already loaded${N}...${Y}Skipping${N}"
# fi

# systemctl restart catalogue 
# VALIDATE "$?" "Restarted catalogue service"

echo -e "${G}catalogue package installation is successfully completed${N} ... ${Y}Thanks you${N}"




