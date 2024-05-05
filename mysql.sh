#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -1f)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\[31m"
G="\[32m"
Y="\[33m"
N="\[0m"

echo "Please enter the password:"
read -e mysql_root_password

VALIDATE={
  if [ $1 -ne 0 ]
  then
    echo -e"$2..$R FAILURE $N"
    exit 1
  else
    echo -e "$2..$G SUCCESS $N"
  fi
}

if [ $USERID -ne 0 ]
then
  echo "Please run this script as root user"
else
  echo "You are a super user"
fi

dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "starting mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
#VALIDATE $? "setting up root password for mysql server"

#below code can be used for idempotent nature

mysql_secure_installation --set-root-pass ${mysql_root_password} -e 'show databases;' &>>LOGFILE
if [ $? -ne 0 ]
then
  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>LOGFILE
  VALIDATE $? "Setting up root password"
else
  echo -e "mysql root password is alreday set up..$Y SKIPPING $N"
fi



