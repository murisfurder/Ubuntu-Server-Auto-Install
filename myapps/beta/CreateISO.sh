#!/bin/bash

#for the case for program yes or no 
#case $answer in
# Y|y|yes|Yes)
# *) for other options
#Example Locations of Ubuntu ISOs
#http://releases.ubuntu.com/16.04/
#http://releases.ubuntu.com/16.04.2/
#http://releases.ubuntu.com/16.10/
#http://releases.ubuntu.com/17.04/
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-desktop-amd64.iso
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-desktop-i386.iso
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-server-amd64.iso
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-server-i386.iso

echo "Fully Automated Script to Download Your Ubuntu ISO, "
echo "Unpack it, edit the MyApps Scripts and then ReImage the ISO back together for you"

echo "Where is the Myapps Folder located at?
echo "If located in Your Home Dir please add the Full location with /home/'username' "
read WorkingDir

rm $WorkingDir/README.md
rm $WorkingDir/_config.yml
echo "Setting up KickStart Config File"

echo "System Language ?"
echo " 'locale' running this Command shows your Current System Setting Format"
read SystemLanguage

#dpkg-reconfigure keyboard-configuration
echo "System Keyboard Setup ?"
read SystemKeyboard

echo "TimeZone ?"
echo "if dont know the format for your timezone check out:"
echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
read TimeZone

echo "Admin Account UserName ?"
read AdminUsername

echo "Admin Account Password ?"
read AdminPassword

echo "Swap Partition Size ?"
echo "Partition Setup as under MB NOT AS GB"
read SwapPartition

echo "Renaming Kickstart Config File"
mv ks-example.cfg ks.cfg

cd $WorkingDir/myapps/

echo "Editing FirstbootInstall.sh File"
echo "What Programs to be installed ?"

echo "Install iRedMail ?"
read Installiredmail

echo "Install Apache2 ?'
echo "If no, No webservers will be installed due to only have Apache2 setup scripts"
read InstallApache2

echo "Install Cerbot (Lets Encrypt Cert) ?"
read InstallCerbot

echo "Install Mysql and PhpMyAdmin ?"
read InstallMysql

echo "Install Noip2 Client ?"
read InstallNoip2

echo "Install Deluge with web UI ?"
read InstallDeluge

echo "Install CouchPotato ?"
read InstallCouchPotato

echo "Install HeadPhones?"
read InstallHeadPhones

echo "Install Mylar ?"
read InstallMylar

echo "Install SickRage ?"
read InstallSickRage

echo "Install Webmin ?"
read InstallWebmin

echo "Install Plex Media Server?"
read InstallPlexServer

echo "Install Emby Media Server?"
read InstallEmbyServer

echo "Install Grive (Google Drvie Sync) ?"
read InstallGrive

echo "Install ZoneMinder?"
read InstallZoneMinder

echo "Install TeamSpeak 3 Server?"
read InstallTeamSpeakServer

echo "Install Sonarr?"
read InstallSonarr

echo "Install Jackett?"
read InstallJackett

echo "Install Samba?"
read InstallSamba

echo "Install Muximux?"
read InstallMuximux

echo "Install HTPC-Manager?"
read InstallHTPCManager

echo "Install LazyLibrarian?"
read InstallLazyLibrarian

echo "Install Shinobi?"
read InstallShinobi

echo "Install MadSonic?"
read InstallMadSonic

echo "Install Organizr?"
read InstallOrganizr

echo "Install Ubooquity?"
read InstallUbooquity

echo "Install Sinusbot?"
read InstallSinusbot

echo "What version of ubuntu?"
echo "Desktop or Server?"
read UbuntuDistro

echo "What Version of Ubuntu?"
read UbuntuDistroVer

echo " i386(32 bit) or amd64 (64 bit) ?"
read UbuntuBit

echo "Downloading Distro"
wget http://releases.ubuntu.com/$UbuntuDistroVer/ubuntu-$UbuntuDistroVer-$UbuntuDistro-$UbuntuBit.iso -O /opt

echo "Creating Iso Folder"
sudo mkdir -p /mnt/iso
cd /opt
sudo mount -o loop ubuntu-$UbuntuDistroVer-$UbuntuDistro-$UbuntuBit.iso /mnt/iso
sudo mkdir -p /opt/serveriso
sudo cp -rT /mnt/iso /opt/serveriso
sudo chmod -R 777 /opt/serveriso/
cd /opt/serveriso
echo $SystemLanguage >isolinux/langlist (to set default/only Language of installer)
#edit /opt/serveriso/isolinux/txt.cfg  At the end of the append line add ks=cdrom:/ks.cfg. You can remove quiet — and vga=788
sed -i 
cp $WorkingDir/myapps /opt/serveriso
echo "Pausing in Case for extra edits of myapss"
read -p "Press [Enter] key to Continue"
#https://www.cyberciti.biz/tips/linux-unix-pause-command.html
sudo mkisofs -D -r -V "ATTENDLESS_UBUNTU" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o /opt/autoinstall.iso /opt/serveriso
sudo chmod -R 777 /opt