if [ -d core ]
then
	echo "Error: core already exists!" >&2
	exit 1
fi

mkdir -p core
cd core
wget http://www.tinycorelinux.net/7.x/x86_64/release/CorePure64-7.0.iso
wget http://www.tinycorelinux.net/7.x/x86/tcz/ipv6-4.2.9-tinycore64.tcz
wget http://www.tinycorelinux.net/7.x/x86/tcz/netfilter-4.2.9-tinycore64.tcz
