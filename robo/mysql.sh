#!/bin/bash

COMPONENT=mysql
Service=nginx
ID=$(id -u)
appuser=roboshop

LOGFILE="/tmp/${COMPONENT}.log"
# Status function to check wheather it success or failure
stat()  {
        if [ $1 -eq 0 ] ; then
            echo -e "\e[33m success \e[0m"
         else   
          echo -e  "\e[31m failure \e[0m"
          exit 2
         fi
       }

echo -e "\e[35m This scripting is for $COMPONENT  \e[0m"

echo -n "To check whether user is root or not "
if [ $ID -ne 0 ] ; then   
echo -e "\e[31m This script will be excuted by Root user or Privileged user \e[0m"
exit 1
else
echo -e "\e[32m User is Root - $ID \e[0m"
fi

echo -e "**************** \e[35m $COMPONENT Installation is started \e[0m **************"

echo -n "Setup $COMPONENT database :"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo &>> $LOGFILE
stat $?

echo -n "Install $COMPONENT database :"
yum install mysql-community-server -y    &>> $LOGFILE
stat $?

echo -n "Starting $COMPONENT database :"
systemctl daemon-reload    &>> $LOGFILE
systemctl enable mysqld    &>> $LOGFILE
systemctl restart mysqld    &>> $LOGFILE
stat $?

echo -n "Fecthing default password :"
DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')
stat $?

echo "show databases;" | mysql -uroot -pRoboShop@1 &>> $LOGFILE
if [ $? -ne 0 ] ; then 
echo -n "Change default password :"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_ROOT_PASSWORD} | &>> $LOGFILE
stat $?
fi



