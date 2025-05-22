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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "installing python"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment application"

cd /app &>> $LOGFILE

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzipping payment file"

cd /app &>> $LOGFILE

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/Roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Demon reload for Payment" 

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling payment" 

systemctl start payment &>> $LOGFILE

VALIDATE $? "starting payment" 