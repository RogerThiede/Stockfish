#!/bin/zsh
##################################################################################################
# usage: store_tablebase_in_ram.sh TABLEBASE_PATH RAMFS_PATH
#
# Creates a RAM Disk (ramfs) at RAMFS_PATH, and copies the contents of TABLEBASE_PATH into it.
# This is useful to override the OS's caching policies and force a folder to always be cached.
# The RAM Disk is then made read-only.
##################################################################################################

TABLEBASE_PATH=${argv[1]} 
RAMFS_PATH=${argv[2]}

if [ ! -d $TABLEBASE_PATH ]
then
	echo "Can't find $TABLEBASE_PATH"
	exit 1
fi

if [ ! -d $RAMFS_PATH ] 
then
	echo "$RAMFS_PATH does not yet exist.  Making directory."
	mkdir $RAMFS_PATH
fi

size=`du -sh $TABLEBASE_PATH`
echo "Storing $size to $RAMFS_PATH"
echo "Please make sure enough free memory is available."

mount -t ramfs ramfs $RAMFS_PATH 
if [ $? -eq 0 ]
then
	rsync -avP $TABLEBASE_PATH $RAMFS_PATH
	mount -t ramfs -o remount,ro,noatime ramfs $RAMFS_PATH
else
	echo "$RAMFS_PATH could not be mounted."
fi


