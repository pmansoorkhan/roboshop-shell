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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>> "$LOG_FILE"

dnf install rabbitmq-server -y   &>> "$LOG_FILE"
VALIDATE "$?" "Installing RabbitMQ"

systemctl enable rabbitmq-server  &>> "$LOG_FILE"
systemctl start rabbitmq-server   &>> "$LOG_FILE"
VALIDATE "$?" "Enabling & Starting RAbbitMQ service"

rabbitmqctl add_user roboshop roboshop123   &>> "$LOG_FILE"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"   &>> "$LOG_FILE"
VALIDATE "$?" "Adding and Giving permissions"

