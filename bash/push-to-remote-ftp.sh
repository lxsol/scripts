#!/bin/sh
# Push cPanel generated backups to remote FTP server
#
# Version: 0.1
# Author: Alex H 
# License: GPL v3 (http://www.gnu.org/licenses/gpl.html)
#
# This script is based on work and ideas from https://code.google.com/p/mycodedump/source/browse/?repo=shellscripts
#
# Dependencies:
# mail, ncftp
#
# Changelog:
# 
# 2014-09-04 / Version 0.1 / initial release


### System Setup ###
DIR="/backup/filesystem/latest/"

### FTP server Setup ###
FTPD="/backup/"
FTPU="ftp-user"
FTPP="pass"
FTPS="ftp.host.com"

### Other stuff ###
EMAILID="your@mail.com"
NOW=$(date +"%Y-%m-%d")

### Libraries ###
NCFTP="$(which ncftp)"
if [ -z "$NCFTP" ]; then
    echo "Error: NCFTP not found"
    exit 1
fi

MAIL="$(which mail)"
if [ -z "$MAIL" ]; then
    echo "Error: mail not found"
    exit 1
fi


### Dump backup using FTP ###
#Start FTP backup using ncftp
$NCFTP -u"$FTPU" -p"$FTPP" $FTPS<<EOF
mkdir $FTPD
cd $FTPD
lcd $DIR
put -DD *
quit
EOF

### Notify if ftp backup failed ###
if [ "$?" != "0" ]; then
    T=backup.fail
    echo "Date: $(date)">$T
    echo "Hostname: $HOST" >>$T
    echo "Backup failed" >>$T
    echo "." >>$T
    echo "" >>$T
    $MAIL  -s "BACKUP FAILED" "$EMAILID" <$T
    rm -f $T
fi
