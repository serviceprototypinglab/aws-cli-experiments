#!/bin/sh

if [ ! -f test.grub.img ]
then
	echo "Error: needs test.grub.img" >&1
	exit 1
fi

size=`stat -c %s test.grub.img`
nsize=$(($size/1048576+1))
dd if=/dev/zero of=disk bs=1M count=$nsize

nsizemb=`python -c "print($nsize * 1048576 / 1000000.0)"`
echo "## $nsize => $nsizemb"

parted disk mklabel msdos
parted disk mkpart primary ext2 1 $nsizemb
parted disk set 1 boot on

dd if=test.grub.img of=disk conv=notrunc bs=1M seek=1

#dd if=/usr/lib/syslinux/mbr/mbr.bin of=disk conv=notrunc

#mount -o offset=1048576 disk /mnt

losetup /dev/loop0 disk
kpartx -s -v -a /dev/loop0
losetup /dev/loop1 /dev/mapper/loop0p1
mount /dev/loop1 /mnt

grub-install --boot-directory=/mnt/boot --target=i386-pc --debug /dev/loop0

umount /mnt
losetup -d /dev/loop1
losetup -d /dev/loop0
kpartx -v -d /dev/loop0
