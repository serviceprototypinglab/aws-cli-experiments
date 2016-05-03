#!/bin/bash
#
# Experiment: Upload under failure conditions and check eventual success
# with retry.
#
# Notes:
# aws configure set default.s3.multipart_chunksize 5MB
# aws s3 cp --chunk-size 5242880 # with aws-s3-retry patches
# here: assume default chunk size (configured to 5MB)

export AWSRETRYDEBUG=1
output=/tmp/tmp.awsretry.$$
log=awsretry-exp.csv
s3url=s3://.../

delay=5000ms
loss=0.0%
# automatic assignment for route to s3.amazon.com
iface=`ip -o route get 72.21.206.80 | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
#iface=wlan0/eth1/...

cleanup()
{
	echo "Emergency reset of interface ${iface}..."
	sudo tc qdisc del dev $iface root
	exit 1
}

trap cleanup SIGTERM SIGINT

sudo tc qdisc add dev $iface root netem delay $delay loss $loss
sudo tc qdisc show

echo "(re)tries,success" >> $log

for i in `seq 10`
do
	./awsretry s3 cp 33mb.img $s3url | tee -a $output

	tries=`grep "return code" $output | wc -l`
	success=`grep "return code: 0" $output | wc -l`

	echo "$tries,$success" >> $log
done

rm $output

sudo tc qdisc del dev $iface root
sudo tc qdisc show
