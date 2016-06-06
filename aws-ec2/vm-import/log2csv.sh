#!/bin/bash

logfile=$1
if [ -z $logfile ]
then
	echo "Syntax: $0 <logfile>" >&2
	exit 1
fi

IFS='
'

echo "time,percent,state" > _importcsv

while read emptyline
do
	read timeline
	read importtaskline
	read snapshotline
	read userbucketline

	if [ -z ${firsttime+x} ]
	then
		firsttime=$timeline
	fi

	deltatime=$(($timeline-$firsttime))
	active=`echo $importtaskline | awk '{print $5}'`
	active8=`echo $importtaskline | awk '{print $8}'`
	percent=`echo $importtaskline | awk '{print $4}'`
	if [ "$active" = "active" ]
	then
		state=`echo $importtaskline | awk '{print $6}'`
	elif [ "$active8" = "active" ]
	then
		state=`echo $importtaskline | awk '{print $9}'`
		percent=`echo $importtaskline | awk '{print $7}'`
	else
		state=$percent
	fi

	echo "* $timeline => $deltatime / $importtaskline => $state"
	if [ "$state" != "$oldstate" ]
	then
		echo "$deltatime,$percent,$state" >> _importcsv
		oldstate=$state
	fi
	sleep 0.001
done < $logfile
