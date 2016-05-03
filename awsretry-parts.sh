#!/bin/bash
#
# Experiment: Like awsretry-exp.sh, but using the internal multipart
# retry functionality to achieve time and bandwidth savings. The failure
# condition can be turned off in `pure' mode.

export AWSRETRY=5
export AWSRETRYDEBUG=1

s3url=s3://.../
pure=0

delay=15000ms
loss=0.0%

# automatic assignment for route to s3.amazon.com
iface=`ip -o route get 72.21.206.80 | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
#iface=wlan0/eth1/...

output=/tmp/tmp.awsretry.$$
log=awsretry-parts.delay-${delay}.${iface}.${AWSRETRY}.csv

cleanup()
{
	echo "Emergency reset of interface ${iface}..."
	sudo tc qdisc del dev $iface root
	exit 1
}

if [ "$pure" = 0 ]
then
	trap cleanup SIGTERM SIGINT

	sudo tc qdisc add dev $iface root netem delay $delay loss $loss
	sudo tc qdisc show
else
	log=awsretry-parts.pure.${iface}.${AWSRETRY}.csv
fi

echo "num,(re)tries,success,overallsuccess,overallsuccesspercent,overhead" >> $log

sumoverallsuccess=0
for i in `seq 10`
do
	echo "---------- round $i" | tee -a $output
	stdbuf -o0 aws s3 cp --chunk-size 5MB 33mb.img $s3url | tee -a $output
	if [ ${PIPESTATUS[0]} = 0 ]
	then
		overallsuccess=1
	else
		overallsuccess=0
	fi

	tries=`grep "return code" $output | wc -l`
	success=`grep "return code: 0" $output | wc -l`
	sumoverallsuccess=$(($sumoverallsuccess+$overallsuccess))
	percent=$((100*$sumoverallsuccess/$i))

	overhead=`python3 -c "print('%3.2f' % ($tries/$success))"`
	if [ $? != 0 ]
	then
		overhead=0.00
	fi

	echo "$i,$tries,$success,$overallsuccess,$percent,$overhead" >> $log
done

rm $output

if [ "$pure" = 0 ]
then
	sudo tc qdisc del dev $iface root
	sudo tc qdisc show
fi
