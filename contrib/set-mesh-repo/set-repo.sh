#!/bin/bash
codename=$(lsb_release -cs)
distro=$(lsb_release -is)
mirror=$1

# cd to script directory
cd $(dirname "$0")

# check if script is running as root
if [ "$EUID" -ne 0 ]
then 
	echo "Please run this script as root"
	exit 1
fi

# set mirror values
if [ "$1" == "cjdns" ]
then
	prefix="h"
elif [ "$1" == "yggdrasil" ]
then
	prefix="y"
elif [ "$1" == "default" ]
then
	# restore default sources
	# Raspbian
	if [ "$distro" == "Raspbian" ]
	then
		echo "Changing to Raspbian $1 repo."
		cp raspbian-default-sources.list /etc/apt/sources.list
		cp raspbian-default-raspi.list /etc/apt/sources.list.d/raspi.list
		sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list
		sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list.d/raspi.list
		echo "Done. Restored to default."
		# exit script with no error
		exit 0
	# Debian / Armbian
	elif [ "$distro" == "Debian" ]
	then
		echo "Changing to Raspbian $1 repo."
		# check if there is /etc/apt/sources.list.d/armbian.list if so replace it
		if [ -f /etc/apt/sources.list.d/armbian.list ]
		then
			cp armbian-default-armbian.list /etc/apt/sources.list.d/armbian.list
			sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list.d/armbian.list
		fi
		cp debian-default-sources.list /etc/apt/sources.list
		sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list
		
		echo "Done. Restored to default."
		# exit script with no error
		exit 0
	else
		echo "Your distro: $distro is not supported."
	fi

else
	echo "Usage: $0 { cjdns | default | yggdrasil }"
	exit 1
fi

# detect distro and apply changes to sources
if [ "$distro" == "Raspbian" ]
then
	echo "Changing to Raspbian $1 repo."
	cp raspbian-sources.list /etc/apt/sources.list
	cp raspbian-raspi.list /etc/apt/sources.list.d/raspi.list

	sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list
	sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list.d/raspi.list
	sed -i "s/__PREFIX__/$prefix/g" /etc/apt/sources.list
	sed -i "s/__PREFIX__/$prefix/g" /etc/apt/sources.list.d/raspi.list
	echo "Done. To restore to default repo run script with option default."

elif [ "$distro" == "Debian" ]
then
	echo "Changing to Debian $1 repo."
	cp debian-sources.list /etc/apt/sources.list
	
	# check if there is /etc/apt/sources.list.d/armbian.list if so replace it
	if [ -f /etc/apt/sources.list.d/armbian.list ]
	then
		cp armbian-armbian.list /etc/apt/sources.list.d/armbian.list
		sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list.d/armbian.list
		sed -i "s/__PREFIX__/$prefix/g" /etc/apt/sources.list.d/armbian.list
	fi

	sed -i "s/__CODENAME__/$codename/g" /etc/apt/sources.list
	sed -i "s/__PREFIX__/$prefix/g" /etc/apt/sources.list
	echo "Done. To restore to default repo run script with option default."
else
	echo "Your distro: $distro is not supported."
fi
