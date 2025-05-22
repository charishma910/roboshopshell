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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling current MYSQL Version" 

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copied MYSQL repo" 

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing MYSQL sever" 

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enabling MYSQL sever" 

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting MYSQL sever" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting MYSQL root password" 
