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
MYSQL_HOST=mysql.shannu.online
SCRIPT_DIR=$PWD
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
VALIDATE "$?" "Copying SHIPPING Service"

dnf install mysql -y  &>> "$LOG_FILE" 
VALIDATE "$?" "Installing MYSQL"


mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ "$?" -ne 0 ]; then
     mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/schema.sql
     mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/app-user.sql 
     mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/master-data.sql
     VALIDATE "$?" "Loading data into MYSQL"
else 
    echo -e "${G} Data is already loaded ${N} .....${Y} Skipping ${N}"
fi
    
systemctl daemon-reload &>> "$LOG_FILE" 
VALIDATE "$?" "Reloading SHIPPING service"

systemctl enable shipping  &>> "$LOG_FILE"
systemctl start shipping   &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting SHIPING Service"

print_total_time(){
    END_TIME="$(date +%s)"
    TOTAL_TIME=$(( "$END_TIME" - "$START_TIME" ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S")  | Script executed in :"${G} $TOTAL_TIME" seconds ${N}"  | tee -a "$LOG_FILE"
}

print_total_time