#!/bin/sh
#
# Experiment: Generate and upload files with different sizes and produce
# a logfile which can be manually analysed for failures.

s3url=s3://.../

for i in `seq 4`
do
	for size in 9 12 15 18 21 24 27 30 33
	do
		fname=${size}mb.img
		if [ ! -f ${fname} ]
		then
			dd if=/dev/urandom of=${fname} bs=${size}M count=1
		fi
		echo ">> attempt $i for ${fname}..."
		aws s3 cp ${size}mb.img ${s3url}
	done
done
