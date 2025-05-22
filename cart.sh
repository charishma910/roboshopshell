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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling version 18 nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs" 

id roboshop  # if roboshop user does not exists then this line will fail
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "creating roboshop user" 
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE  #-p will checks already exists or not, If exists it wont create again

VALIDATE $? "creating app directory" 

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application" 

cd /app &>> $LOGFILE

unzip /tmp/cart.zip &>> $LOGFILE   # -o for overwrite the exisisting files

VALIDATE $? "unzipping cart" 

cd /app

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

#use absolute path since catalogue.service exists there
cp /home/centos/Roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying cart service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart demon reload" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enable cart" 

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart" 

