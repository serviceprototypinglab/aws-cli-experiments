#!/bin/bash

importami=$1
if [ -z $importami ]
then
	echo "Syntax: $0 <importami>" >&2
	exit 1
fi

if [ -f _importlog ]
then
	mv _importlog _importlog.previous
fi

while true
do
	echo
	date +%s
	#aws ec2 describe-import-image-tasks
	aws ec2 describe-import-image-tasks --cli-input-json "{\"ImportTaskIds\": [\"$importami\"]}"
	sleep 1
done | tee -a _importlog
