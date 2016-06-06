all:
	@echo "This is not an easy makefile."

qemuimage:
	qemu-img create -f raw test.img 70M
	/sbin/mkfs.ext2 -m 0 test.img
	sudo mount -o loop test.img /mnt/
	sudo mkdir -p /mnt/lib64
	sudo cp core/ramdisk/lib/ld-2.22.so /mnt/lib64/ld-linux-x86-64.so.2
	sudo cp bzImage-recvirt-kvm-unicore extlinux.conf /mnt/
	sudo cp _xen_kernel/linux-4.5.2/arch/x86/boot/bzImage /mnt/vmlinuxen	# * not needed for local kvm
	sudo cp initramfs/initramfs.gz /mnt/					# * not neeed for local kvm
	sudo mkdir -p /mnt/proc
	sudo cp /bin/busybox /mnt/
	sudo ln -s busybox /mnt/sh
	sudo ln -s busybox /mnt/mount
	sudo cp initramfs/sfiinit /mnt/
	sudo chmod +x /mnt/sfiinit
	sudo extlinux --install /mnt/
	df -Th /mnt
	sudo umount /mnt

#COREIMAGE = Core-current.iso
COREIMAGE = CorePure64-7.0.iso
#CORERAMDISK = core.gz
CORERAMDISK = corepure64.gz

coreimage: .core_unpack .core_extract .core_customise .core_compress .core_repack

.core_unpack:
	sudo rm -rf core/unpack core/ramdisk
	mkdir core/unpack core/ramdisk
	sudo mount -o loop,ro core/$(COREIMAGE) /mnt/
	cp -r /mnt/* core/unpack
	sudo umount /mnt/

.core_extract:
	cd core/ramdisk && zcat ../unpack/boot/$(CORERAMDISK) | sudo cpio -i -d -H newc
##	cp core/unpack/boot/$(CORERAMDISK) core/ramdisk
##	gzip -d core/ramdisk/$(CORERAMDISK)
##	cd core/ramdisk && sudo cpio -i -d -H newc < core && rm -f core

.core_customise:
	sudo cp /usr/bin/micro-inetd core/ramdisk/opt/
	echo "su -c 'tce-load -i /tmp/tce/optional/ipv6-4.2.9-tinycore64.tcz' tc" | sudo tee -a core/ramdisk/opt/bootlocal.sh >/dev/null
	echo "/opt/micro-inetd 10001 /bin/true" | sudo tee -a core/ramdisk/opt/bootlocal.sh >/dev/null
	sudo ln -s lib core/ramdisk/lib64
	sudo mkdir -p core/ramdisk/tmp/tce/optional
	sudo cp core/*.tcz core/ramdisk/tmp/tce/optional
	#sudo sed -i -e 's/prompt 1/prompt 0/' core/unpack/boot/isolinux/isolinux.cfg
	sudo sed -i -e 's/vmlinuz64/vmlinuxen/' core/unpack/boot/isolinux/isolinux.cfg
	sudo cp _xen_kernel/linux-4.5.2/arch/x86/boot/bzImage core/unpack/boot/vmlinuxen
	sudo mkdir -p core/ramdisk/lib/modules/4.5.2
	sudo touch core/ramdisk/lib/modules/4.5.2/modules.dep

.core_compress:
	cd core/ramdisk && find | sudo cpio -o -H newc | gzip -9 > /tmp/$(CORERAMDISK) && mv -f /tmp/$(CORERAMDISK) .
## FIXME: permission issue? unbootable ISO!
##	cd core/ramdisk && find . -depth -print | sudo cpio -o -H newc > /tmp/core && mv -f /tmp/core .
##	chmod 0444 core/ramdisk/core && gzip -9 core/ramdisk/core
	#advdef -z4 ramdisk/$(CORERAMDISK)
	chmod +w core/unpack/boot/$(CORERAMDISK)
	cp core/ramdisk/$(CORERAMDISK) core/unpack/boot/$(CORERAMDISK)
	chmod -w core/unpack/boot/$(CORERAMDISK)

.core_repack:
	sudo genisoimage -l -J -R -V TC-custom -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o core/TC-remastered.iso core/unpack/

cloud: diskimage vmimage cloudimage

diskimage:
	#count=$((`stat -c %s core/TC-remastered.iso`/1024/1024+10))
	dd if=/dev/zero of=core/mydisk.img bs=1M count=30
	/sbin/mkfs.ext2 core/mydisk.img
	sudo mkdir -p /mnt/iso /mnt/disk
	sudo mount -o loop core/mydisk.img /mnt/disk/
	sudo mount -o loop,ro core/TC-remastered.iso /mnt/iso/
	sudo cp -a /mnt/iso/* /mnt/disk/
	sudo rm -rf /mnt/disk/isolinux
	sudo mkdir -p /mnt/disk/boot/extlinux
	sudo cp extlinux-core.conf /mnt/disk/boot/extlinux/extlinux.conf
	sudo extlinux --install /mnt/disk/boot/extlinux/
	sudo umount /mnt/iso/ /mnt/disk/

vmimage:
	VBoxManage convertfromraw core/mydisk.img core/mydisk.vdi

#id=`uuidgen`
BUCKETNAME=.....

cloudimage:
	aws s3 mb s3://$(BUCKETNAME)/ || true
	AWSRETRYDEBUG=1 AWSRETRY=-1 aws s3 cp core/mydisk.ova s3://$(BUCKETNAME)/

rawimage:
	#VBoxManage clonehd minimalvm-pvgrub64-4.vdi minimalvm-pvgrub64-4.img --format RAW
	#qemu-img convert -f vdi minimalvm-pvgrub64-4.vdi -O raw minimalvm-pvgrub64-4.img
	#echo "does not boot after grub!?"
	tar xf minimalvm-pure.ova minimalvm-pure-disk1.vmdk -O > _test.vmdk
	qemu-img convert -f vmdk _test.vmdk -O raw pureraw.img
	rm -f _test.vmdk
	#sudo mount -o loop,offset=1048576 pureraw.img /mnt/
