#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

MYSQL_HOST=MYSQL-SERVER-IPADDRESS

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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping application" 

cd /app &>> $LOGFILE

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping" 

mvn clean package &>> $LOGFILE

VALIDATE $? "installing dependencies" 

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming jar file" 

cp /home/centos/Roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "copying shipping service" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "demon reload" 

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "enabling shipping" 

systemctl start shipping &>> $LOGFILE

VALIDATE $? "starting shipping" 

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE

VALIDATE $? "loading shipping data" 

mysql -h MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

mysql -h MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "restarting catalogue" 