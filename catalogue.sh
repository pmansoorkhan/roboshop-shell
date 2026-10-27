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
MONGODB_HOST=mongodb.shannu.online

# Check root user
if [ "$USER_ID" -ne 0 ]; then
    echo -e "${R}Please run the script as root user${N}" | tee -a "$LOG_FILE"
    exit 1
fi
mkdir -p "$LOG_FOLDER"  

VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 .... is ${R}failed${N}" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2 ...... is ${G}successful${N}" | tee -a "$LOG_FILE"
    fi
}

dnf module list nodejs &>> "$LOG_FILE"
VALIDATE "$?" "checking NODEJS module list"

dnf module  disable nodejs -y &>> "$LOG_FILE"
VALIDATE "$?" "disabling the NODEJS module"

dnf module enable nodejs:20 -y &>> "$LOG_FILE"
VALIDATE "$?" "Enabling the NODEJS module"

dnf install nodejs -y &>> "$LOG_FILE"
VALIDATE "$?" "Installing NODEJS"

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
VALIDATE "$?" "Removing existing content from app directory"

unzip /tmp/catalogue.zip  &>> "$LOG_FILE"
VALIDATE "$?" "Extracting catalogue zip file"

npm install  &>> "$LOG_FILE"
VALIDATE "$?" "Installing nodejs dependencies"

cp "$SCRIPT_DIR/catalogue.service"  /etc/systemd/system/catalogue.service &>> "$LOG_FILE"
VALIDATE "$?" "copying catalogue service file"

systemctl daemon-reload &>> "$LOG_FILE"
VALIDATE "$?" "Reloading systemd daemon service"

systemctl enable catalogue  &>> "$LOG_FILE"
systemctl start catalogue &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting catalogue service"

cp "$SCRIPT_DIR/mongo.repo"  /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
VALIDATE "$?" "copying mongo repo file"

dnf install mongodb-mongosh -y &>> "$LOG_FILE"
VALIDATE "$?" "Installing mongodb shell"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

#INDEX=$(mongosh --host "$MONGODB_HOST:27017" --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')  | tee -a "$LOG_FILE"
#INDEX=$(mongosh --host "mongodb.shannu.online:27017" --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ "$INDEX" -le  0 ]; then 
    mongosh --host "$MONGODB_HOST" </app/db/master-data.js &>> "$LOG_FILE"
    VALIDATE "$?" "Loading catalogue products"
else
 echo -e "${G}catalogue products already loaded${N}......${Y}Skipping${N}"  
fi

systemctl restart catalogue  &>> "$LOG_FILE"
VALIDATE "$?" "Restarted catalogue service"



# #!/bin/bash
# USERID=$(id -u)
# LOGS_FOLDER="/var/log/shell-roboshop"
# LOGS_FILE="$LOGS_FOLDER/$0.log"
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# SCRIPT_DIR=$PWD
# MONGODB_HOST=mongodb.shannu.online

# if [ $USERID -ne 0 ]; then
#     echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
#     exit 1
# fi

# mkdir -p $LOGS_FOLDER

# VALIDATE(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
#         exit 1
#     else
#         echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
#     fi
# }

# dnf module disable nodejs -y &>>$LOGS_FILE
# VALIDATE $? "Disabling NodeJS Default version"

# dnf module enable nodejs:20 -y &>>$LOGS_FILE
# VALIDATE $? "Enabling NodeJS 20"

# dnf install nodejs -y &>>$LOGS_FILE
# VALIDATE $? "Install NodeJS"

# id roboshop &>>$LOGS_FILE
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
#     VALIDATE $? "Creating system user"
# else
#     echo -e "Roboshop user already exist ... $Y SKIPPING $N"
# fi

# mkdir -p /app 
# VALIDATE $? "Creating app directory"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOGS_FILE
# VALIDATE $? "Downloading catalogue code"

# cd /app
# VALIDATE $? "Moving to app directory"

# rm -rf /app/*
# VALIDATE $? "Removing existing code"

# unzip /tmp/catalogue.zip &>>$LOGS_FILE
# VALIDATE $? "Uzip catalogue code"

# npm install  &>>$LOGS_FILE
# VALIDATE $? "Installing dependencies"

# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
# VALIDATE $? "Created systemctl service"

# systemctl daemon-reload
# systemctl enable catalogue  &>>$LOGS_FILE
# systemctl start catalogue
# VALIDATE $? "Starting and enabling catalogue"

# cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
# dnf install mongodb-mongosh -y &>>$LOGS_FILE

# INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

# if [ $INDEX -le 0 ]; then
#     mongosh --host $MONGODB_HOST </app/db/master-data.js
#     VALIDATE $? "Loading products"
# else
#     echo -e "Products already loaded ... $Y SKIPPING $N"
# fi

# systemctl restart catalogue
# VALIDATE $? "Restarting catalogue"