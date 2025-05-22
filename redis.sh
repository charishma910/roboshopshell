#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.5.rpm -y

VALIDATE $? "installing remi release" 

dnf module reset redis -y

VALIDATE $? "resetting redis" 

dnf module enable redis:remi-6.2 -y

VALIDATE $? "enabling remi v6.2" 

dnf install redis -y

VALIDATE $? "installing redis" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

VALIDATE $? "allowing Remote access"

systemctl enable redis

VALIDATE $? "enabling redis" 

systemctl start redis

VALIDATE $? "starting redis" 

