#! /bin/bash

# Script to configure basic system after installation

up_ifs=$(ip -br a | grep -P ".*UP" | awk '{print $1}')
pkgs="fish htop kexec-tools exfatprogs plocate drm-info kbd acpi vim lm-sensors"
# update system
apt update && \
	yes | apt upgrade
# install software
echo "Installing packages: $pkgs"
yes | apt install $pkgs

# enable WOL
for i in $up_ifs; do
	if ethtool $i 2>/dev/null | grep -q "Wake-on:.*g"; then
		ethtool -s $i wol g && \
			echo "Wake-on with 'g' is enabled on $i"
	else
		echo "Wake-on with 'g' is NOT enabled on $i"
	fi
done

# miscellaneous
updatedb &
chsh -s /usr/bin/fish

