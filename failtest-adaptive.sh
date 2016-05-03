#!/bin/bash
#
# Experiment: Upload the same file in multipart mode with different part
# sizes.

delay=5000ms
loss=0.0%
# automatic assignment for route to s3.amazon.com
iface=`ip -o route get 72.21.206.80 | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
#iface=wlan0/eth1/...

testfile=33mb.img
testbucket=s3://.../

cleanup()
{
	echo "Emergency reset of interface ${iface}..."
	sudo tc qdisc del dev $iface root
	exit 1
}

trap cleanup SIGTERM SIGINT

log=failtest-adaptive.eduroam.${delay}.${iface}.ext.log

sudo tc qdisc add dev $iface root netem delay $delay loss $loss
sudo tc qdisc show

echo "# round,chunksize(bytes),ret" >> $log

for i in `seq 5`; do
	for chunksize in 5242880 8388608 16777216; do
		linkstatus=`ip link show $iface | head -1 | sed 's/.*state \([A-Z]*\).*/\1/'`
		while [ $linkstatus != "UP" ]; do
			echo "link ${iface} down or dormant - re-establish to continue!"
			sleep 5
		done
		time aws s3 cp --chunk-size=$chunksize $testfile $testbucket
		ret=$?
		echo "$i,$chunksize,$ret" >> $log
	done
done

sudo tc qdisc del dev $iface root
sudo tc qdisc show
