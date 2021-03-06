#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This Script must be run as root"
	exit 1
fi

## get packages required to build deluge ##
echo "<--- Adding Deluge Team Dep Packages--->"
add-apt-repository -y ppa:deluge-team/ppa
apt update

## setup deluge user
echo "<--- Now we will setup a user for Deluge --->"
adduser --disabled-password --system --home /var/lib/deluge --gecos "Deluge service" --group deluge

touch /var/log/deluged.log
touch /var/log/deluge-web.log
chown deluge:deluge /var/log/deluge*

apt update; apt install deluged deluge-webui -y

echo "Creating New Startup Script"
cp /opt/install/Deluge/deluged.service /etc/systemd/system/
cp /opt/install/Deluge/deluge-web.service /etc/systemd/system/
chmod 644 /etc/systemd/system/deluged.service
chmod 644 /etc/systemd/system/deluge-web.service
systemctl enable deluged.service
systemctl enable deluge-web.service
systemctl start deluged
systemctl start deluge-web
sleep 15

echo "<--Restoring Deluge Settings and Switch to Systemctl startup scripts-->"
#defaults settings stored at /var/lib/deluge/.config/deluge
#core.conf and web.conf
#cp /opt/install/Deluge/core.conf /var/lib/deluge/.config/deluge
#cp /opt/install/Deluge/web.conf /var/lib/deluge/.config/deluge

systemctl stop deluged
systemctl stop deluge-web
sleep 15
sudo chmod 0777 -R /var/lib/deluge/
cp /opt/install/Deluge/core.conf /var/lib/deluge/.config/deluge
cp /opt/install/Deluge/web.conf /var/lib/deluge/.config/deluge
systemctl start deluged
systemctl start deluge-web
