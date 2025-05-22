#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script Started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 ne 0 ]
    then
        echo -e "$2.... $R FAILED $N"
        exit 1
    else
        echo -e "$2.... $G SUCCESS $N"
    fi   
}
if [ $ID -ne 0 ]
then 
    echo "$R ERROR:: Please run this script with root access $N"

    exit 1 # we can give other than 0
else
    echo "you are a root user"
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Downloading erland script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Downloading rabbitMQ script"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "Installing rabbitMQ server"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "Enabling rabbitMQ server"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "starting rabbitMQ server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "setting permissions"