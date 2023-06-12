#!/bin/bash

COMPONENT=shipping
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

echo -n "Installing Maven :"
yum install maven -y
stat $?

echo -n "Check $appuser user exist or not :"
id $appuser &>> $LOGFILE
if [ $? -ne 0 ] ; then
echo -n "Creating $appuser user : "
useradd $appuser &>> $LOGFILE
echo -n "User $appuser created."
else
echo -n "User $appuser exist. "
fi
stat $?

echo -n "Download $COMPONENT repo :"
cd /home/$appuser
curl -s -L -o /tmp/shipping.zip "https://github.com/stans-robot-project/shipping/archive/main.zip" &>> $LOGFILE
stat $?

echo -n "Unzipping $COMPONENT :"
unzip /tmp/$COMPONENT.zip
stat $?

echo -n "Clean $COMPONENT package:"
mv $COMPONENT-main $COMPONENT
cd $COMPONENT
mvn clean package 
mv target/$COMPONENT-1.0.jar $COMPONENT.jar
stat $?

echo -n "Updated the $COMPONENT system file :"
sed -i -e 's/CARTENDPOINT/cart.roboshop.online/' -e 's/DBHOST/mysql.roboshop.online/' /home/${appuser}/${COMPONENT}/systemd.service
mv /home/${appuser}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Starting $COMPONENT :"
systemctl daemon-reload   &>> $LOGFILE
systemctl enable $COMPONENT  &>> $LOGFILE
systemctl restart $COMPONENT   &>> $LOGFILE
stat $?

