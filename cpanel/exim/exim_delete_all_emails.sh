#!/bin/bash
EXIM=`which exim`
$EXIM -bp | awk '/^ *[0-9]+[mhd]/{print "exim -Mrm " $3}' | bash && /etc/init.d/exim restart
