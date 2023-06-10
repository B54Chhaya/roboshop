#!/bin/bash

COMPONENT=mongodb
Service=mongod
ID=$(id -u)

#source robo/common.sh

LOGFILE="/tmp/${COMPONENT}.log"

#Status function to check wheather it success or failure
stat()  {
        if [ $1 -eq 0 ] ; then
            echo -e "\e[33m success \e[0m"
         else   
          echo -e  "\e[31m failure \e[0m"
          exit 2
         fi
       }

echo -e "\e[35m This scripting is for MongoDb \e[0m"

echo -n "To check whether user is root or not :"
 if [ $ID -ne 0 ] ; then   
      echo -e "\e[31m This script will be excuted by Root user or Privileged user \e[0m"
      exit 1
else
      echo -e "\e[32m User is Root - $ID \e[0m"
fi

echo -n "Configuring the $COMPONENT repo:"
curl -s -o /etc/yum.repos.d/$COMPONENT.repo https://raw.githubusercontent.com/stans-robot-project/$COMPONENT/main/mongo.repo &>> "/tmp/${COMPONENT}.log"
stat $?

# Installing Mongo Db
echo -n "Installing $COMPONENT :"
yum install -y $COMPONENT-org  &>> $LOGFILE
stat $?

echo -n "starting $COMPONENT service :"
systemctl enable $Service &>> $LOGFILE
systemctl start $Service &>> $LOGFILE
stat $?

echo -n "Enabling the DB visibility :"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/$service.conf
stat $?


