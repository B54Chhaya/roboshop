#!/bin/bash

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