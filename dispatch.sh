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

dnf install golang -y &>> $LOGFILE

id roboshop  # if roboshop user does not exists then this line will fail
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "creating roboshop user" 
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

mkdir /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Downloading Dispatch application" 

cd /app &>> $LOGFILE

unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "unzipping Dispatch" 

cd /app &>> $LOGFILE
go mod init dispatch &>> $LOGFILE
go get &>> $LOGFILE
go build &>> $LOGFILE

cp /home/centos/Roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "copying Dispatch service" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Dispatch demon reload"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "enabling Dispatch" 

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "starting Dispatch" 