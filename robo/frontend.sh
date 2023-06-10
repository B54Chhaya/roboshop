#!/bin/bash

COMPONENT=frontend
Service=nginx
ID=$(id -u)

source robo/common.sh


# Status function to check wheather it success or failure
#stat()  {
#        if [ $1 -eq 0 ] ; then
#            echo -e "\e[33m success \e[0m"
#         else   
#          echo -e  "\e[31m failure \e[0m"
#          exit 2
#         fi
#       }


echo -e "\e[35m This scripting is for Frontend \e[0m"

echo "To check whether user is root or not "

if [ $ID -ne 0 ] ; then   
echo -e "\e[31m This script will be excuted by Root user or Privileged user \e[0m"
exit 1
else
echo -e "\e[32m User is Root - $ID \e[0m"
fi

echo -e "\e[32m This will install $Service server on $COMPONENT server \e[0m"

# Installing Nginx
echo -n "Installing $Service :"
yum install nginx -y &>> "/tmp/${COMPONENT}.log"
stat $?


# download the HTDOCS content and deploy it under the Nginx path "="
echo -n "This will download $COMPONENT content :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip" &>> "/tmp/${COMPONENT}.log"
stat $?

#Performing clean of logs
echo -n "Performing cleanup :"
cd /usr/share/nginx/html
rm -rf * &>> "/tmp/${COMPONENT}.log"
stat $?

#unzipping file
echo -n "Extracting ${COMPONENT} component :"
unzip /tmp/${COMPONENT}.zip   &>> "/tmp/${COMPONENT}.log"
mv ${COMPONENT}-main/* .
mv static/* .    &>> "/tmp/${COMPONENT}.log"
rm -rf ${COMPONENT}-main README.md
mv localhost.conf /etc/${Service}/default.d/roboshop.conf
stat $?

echo -n "starting ${COMPONENT} service :"
systemctl enable $Service &>> $LOGFILE
systemctl start $Service &>>  $LOGFILE
stat $?
