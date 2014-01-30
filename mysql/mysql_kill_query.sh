#!/bin/bash
if [ "$1" == "root" ]
   then
 echo " ";
 echo -e "\033Cannot kill root dude.";
 echo -e "\033If you want to, you will need to do it manually";
  elif  [ "$1" == "" ]
   then
 echo -e "\033Usage is qkill cpuser or qkill cpuser_db"
 echo -e "\033Try again, but please use an argument"
   else
 for i in `mysqladmin processlist |grep $1 | awk {'print $2'}`; do `mysqladmin kill $i`; done

  echo -e "\033Queries for $1 are now killed.";
fi
