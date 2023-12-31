#!/bin/bash

COMPONENT=cart
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

echo -n "Configuring $COMPONENT repo :"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash - &>> $LOGFILE
stat $?

echo -n "Installing NodeJs :"
yum install nodejs -y &>> $LOGFILE
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

echo -n "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "Copying the $COMPONENT to $appuser home directory :"
#chown -R $appuser:$appuser /home/roboshop/
cd /home/${appuser}/
rm -rf ${COMPONENT}
unzip -o /tmp/$COMPONENT.zip  &>> $LOGFILE
stat $?

echo -n "Modifying the ownsership:"
mv $COMPONENT-main/ $COMPONENT
chown -R $appuser:$appuser /home/roboshop/$COMPONENT/
stat $?

echo -n "Generating npm $COMPONENT artificats :"
cd /home/${appuser}/${COMPONENT}/
npm install &>> $LOGFILE
stat $?

echo -n "Updated the $COMPONENT system file :"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.online/' /home/${appuser}/${COMPONENT}/systemd.service
mv /home/${appuser}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Starting $COMPONENT :"
systemctl daemon-reload   &>> $LOGFILE
systemctl enable $COMPONENT  &>> $LOGFILE
systemctl restart $COMPONENT   &>> $LOGFILE
stat $?

echo -e "**************** \e[35m $COMPONENT Installation is completed \e[0m **************"

