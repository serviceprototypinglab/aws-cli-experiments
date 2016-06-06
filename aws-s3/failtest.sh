#!/bin/bash
#
# Experiment: Single-shot fail testing under artificially worsened
# network conditions with and without retry option.

s3url=s3://.../

delay=5000ms
loss=0.0%

echo "## NETEM: delay $delay loss $loss"

sudo tc qdisc add dev wlan0 root netem delay $delay loss $loss
sudo tc qdisc show

time aws s3 cp 9mb.img $s3url

echo "## RET without retry: $?"

time ./awsretry s3 cp 9mb.img $s3url

echo "## RET with retry: $?"

sudo tc qdisc del dev wlan0 root netem delay $delay loss $loss
sudo tc qdisc show
