#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
RABBITMQ_USER="roboshop"
RABBITMQ_PASSWORD="roboshop123"
SCRIPT_DIR=$PWD
START_TIME="$(date +%s)"
mkdir -p "$LOG_FOLDER"     # Create log directory
echo "$(date "+%Y-%m-%d %H:%M:%S")  | Script started executing at:$(date)"  | tee -a "$LOG_FILE"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>> "$LOG_FILE"

dnf install rabbitmq-server -y   &>> "$LOG_FILE"
VALIDATE "$?" "Installing RabbitMQ"

systemctl enable rabbitmq-server  &>> "$LOG_FILE"
systemctl start rabbitmq-server   &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting RAbbitMQ service"


rabbitmqctl add_user "$RABBITMQ_USER" "$RABBITMQ_PASSWORD" &>> "$LOG_FILE"
rabbitmqctl set_permissions -p / "$RABBITMQ_USER" ".*" ".*" ".*" &>> "$LOG_FILE"
#rabbitmqctl add_user roboshop roboshop123   &>> "$LOG_FILE"
#rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"   &>> "$LOG_FILE"
VALIDATE "$?" "Adding and Giving permissions"

print_total_time(){
    END_TIME="$(date +%s)"
    TOTAL_TIME=$(( "$END_TIME" - "$START_TIME" ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S")  | Script executed in :"${G} $TOTAL_TIME" seconds ${N}"  | tee -a "$LOG_FILE"
}

print_total_time