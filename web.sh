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

dnf install nginx -y &>> $LOGFILE  

VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE 

VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE 

VALIDATE $? "starting nginx" 

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 

VALIDATE $? "remoove default website" 

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE 

VALIDATE $? "Downlodaing web application" 

cd /usr/share/nginx/html &>> $LOGFILE 

VALIDATE $? "moving to nginx html directory " 

unzip /tmp/web.zip &>> $LOGFILE 

VALIDATE $? "unzipping web" 

cp /home/centos/Roboshop-shell/roboshop.conf /etc/systemd/system/roboshop.conf &>> $LOGFILE

VALIDATE $? "roboshop reverse proxy config" 

systemctl restart nginx &>> $LOGFILE 

VALIDATE $? "restart nginx" 