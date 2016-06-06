IRFS = _work/initramfs

all: mkinitramfs packinitramfs

mkinitramfs:
	rm -rf $(IRFS)
	bash -c "mkdir -p $(IRFS)/{bin,sbin,etc,proc,sys,newroot}"
	bash -c "mkdir -p $(IRFS)/usr/{bin,sbin}"
	#touch $(IRFS)/etc/mdev.conf
	cp /bin/busybox $(IRFS)/bin/
	ln -s busybox $(IRFS)/bin/sh
	cp init $(IRFS)/
	chmod +x $(IRFS)/init

packinitramfs:
	cd $(IRFS) && find . | cpio -H newc -o > $(PWD)/initramfs.cpio
	cat initramfs.cpio | gzip > initramfs.gz
