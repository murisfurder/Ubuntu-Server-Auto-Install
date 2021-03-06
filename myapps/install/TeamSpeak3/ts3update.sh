#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#if theres issues with install, install mysql-server

#Modes (Variables)
# b=backup i=install ri=reinstall r=restore u=update U=Force Update 
mode="$1"

server=/opt/ts3
backupdir=/opt/backup/ts3
dl=/tmp
BK=$(cat $server/version)
time=$(date +"%m_%d_%y-%H_%M")

echo "Preforming System Check Up and Getting Latest Version Number from TeamSpeak"
#System Specs
arch=$(uname -m)
if [ "$arch" == "x86_64" ]; then
    arch="amd64"
else
    arch="x86"
fi

sudo apt install libmariadb2

echo "Making sure Backup Dir exists"
mkdir -p $backupdir

echo "Getting Current Version Info"
wget -q https://www.teamspeak.com/downloads --output-document=$dl/Temp
Version=$(grep -Pom 1 "server_linux_$arch-\K.*?(?=\.tar\.bz)" $dl/Temp)
rm $dl/Temp
if [ "$Version" == "" ]; then
    echo "Failed to get Current version!"
    exit
fi


case $mode in
    (-b)
    echo "Stopping TS3 Server"
		systemctl stop ts3
		echo "Backing up TS3 Folder to /opt/backup"
		tar -zcvf $backupdir/ts3_FullBackup-$time.tar.gz $server
		echo "Starting Updated Server"
		systemctl start ts3
		;;
    (-i)
    	echo "Creating Teamspeak User account"
			sudo adduser --no-create-home --disabled-password --gecos "TeamSpeak Server" teamspeak
			echo "Downloading Latest Version of TeamSpeak 3 Server"
			wget -nv http://teamspeak.gameserver.gamed.de/ts3/releases/$Version/teamspeak3-server_linux_$arch-$Version.tar.bz2 --output-document=$dl/package.tar.bz2
			echo "Installing TS3 Server Version $Version"
			tar -xjf $dl/package.tar.bz2 -C $dl/
			mv $dl/teamspeak3-server_linux_$arch/* $server
			rm $dl/package.tar.bz2
			sudo ln -s /opt/ts3/redist/libmariadb.so.2 /opt/ts3/libmariadb.so.2
			sudo touch /opt/ts3/query_ip_blacklist.txt
			echo "127.0.0.1" > /opt/ts3/query_ip_whitelist.txt
			cat /opt/install/TeamSpeak3/ts3server.txt > /opt/ts3/ts3server.ini
			cat /opt/install/TeamSpeak3/ts3db_mariadb.txt > /opt/ts3/ts3db_mariadb.ini
			chmod 0777 /opt/ts3 -R
			chown teamspeak:teamspeak /opt/ts3 -R
			echo "Creating Startup Script"
			cp /opt/install/TeamSpeak3/ts3.service /etc/systemd/system/
			chmod 644 /etc/systemd/system/ts3.service
			systemctl enable ts3.service
			systemctl restart ts3.service
    	;;
    (-r) 
    echo "Stopping TS3 Server"
		systemctl stop ts3
		echo "Location with the file name and type of the backup to be restored?"
		echo "Ex. /opt/backup/ts3_FullBackup-xxx.tar.gz"
		read restorebackup
		echo "Untar Zip file to /opt/ts3"
		tar -xjf $restorebackup /opt/ts3
				echo "Starting TS3 Server"
		systemctl start ts3
		;;
    (-ri) 
    echo "Stopping TS3 Server"
		systemctl stop ts3
		echo "1) 'Clean' Install"
		echo "2) 'Reinstall' over Current Installation"
		read rianswer
    	case $rianswer in
        Clean)
        	rm -rf $server
          echo "Creating Teamspeak User account"
					sudo adduser --no-create-home --disabled-password --gecos "TeamSpeak Server" teamspeak
					echo "Downloading Latest Version of TeamSpeak 3 Server"
					wget -nv http://teamspeak.gameserver.gamed.de/ts3/releases/$Version/teamspeak3-server_linux_$arch-$Version.tar.bz2 --output-document=$dl/package.tar.bz2
					echo "Installing TS3 Server Version $Version"
					tar -xjf $dl/package.tar.bz2 -C $dl/
					mv $dl/teamspeak3-server_linux_$arch/* $server
					rm $dl/package.tar.bz2
					sudo ln -s /opt/ts3/redist/libmariadb.so.2 /opt/ts3/libmariadb.so.2
					sudo touch /opt/ts3/query_ip_blacklist.txt
					echo "127.0.0.1" > /opt/ts3/query_ip_whitelist.txt
					cat /opt/install/TeamSpeak3/ts3server.txt > /opt/ts3/ts3server.ini
					cat /opt/install/TeamSpeak3/ts3db_mariadb.txt > /opt/ts3/ts3db_mariadb.ini
					chmod 0777 /opt/ts3 -R
					chown teamspeak:teamspeak /opt/ts3 -R
					echo "Creating Startup Script"
					cp /opt/install/TeamSpeak3/ts3.service /etc/systemd/system/
					chmod 644 /etc/systemd/system/ts3.service
					systemctl enable ts3.service
					systemctl restart ts3.service
        	exit 0;;
        Reinstall)
        	echo "Stopping TS3 Server"
					systemctl stop ts3
					echo "Running Backup of Settings and DB of TeamSpeak Server Before Update"
					cp $server/query_ip_blacklist.txt $backupdir
					cp $server/query_ip_whitelist.txt $backupdir
					cp $server/ts3server.ini $backupdir
					cp $server/ts3db_mariadb.ini $backupdir
					cp $server/ts3server.sqlitedb $backupdir
					echo "Downloading Latest Version of TeamSpeak 3 Server"
					wget -nv http://teamspeak.gameserver.gamed.de/ts3/releases/$Version/teamspeak3-server_linux_$arch-$Version.tar.bz2 --output-document=$dl/package.tar.bz2
					echo "Installing TS3 Server Version $Version"
					tar -xjf $dl/package.tar.bz2 -C $dl/
					cp -rf $dl/teamspeak3-server_linux_$arch/* $server
					rm $dl/package.tar.bz2
					echo "Moving back Settings and DB back to TS3 Folder"
					mv $backupdir/query_ip_blacklist.txt $server
					mv $backupdir/query_ip_whitelist.txt $server
					mv $backupdir/ts3server.ini $server
					mv $backupdir/ts3db_mariadb.ini $server
					mv $backupdir/ts3server.sqlitedb $server
					echo $Version > $server/version
					echo "Starting Updated Server"
					systemctl start ts3
  	      exit 0;;
    	esac
		echo "Starting TS3 Server"
		systemctl start ts3 
		;;
    (-u) 
    if [ "$BK" == "$Version" ]; then
    		echo "Server is up to date! Latest Version is $Version. If you want to still install over Installation"
    		echo "Run Script with '-U' to Force Update"
    		exit 0
		fi
		echo "Stopping TS3 Server"
		systemctl stop ts3
		echo "Running Backup of Settings and DB of TeamSpeak Server Before Update"
		cp $server/query_ip_blacklist.txt $backupdir
		cp $server/query_ip_whitelist.txt $backupdir
		cp $server/ts3server.ini $backupdir
		cp $server/ts3db_mariadb.ini $backupdir
		cp $server/ts3server.sqlitedb $backupdir
		echo "Downloading Latest Version of TeamSpeak 3 Server"
		wget -nv http://teamspeak.gameserver.gamed.de/ts3/releases/$Version/teamspeak3-server_linux_$arch-$Version.tar.bz2 --output-document=$dl/package.tar.bz2
		echo "Installing TS3 Server Version $Version"
		tar -xjf $dl/package.tar.bz2 -C $dl/
		cp -rf $dl/teamspeak3-server_linux_$arch/* $server
		rm $dl/package.tar.bz2
		echo "Moving back Settings and DB back to TS3 Folder"
		mv $backupdir/query_ip_blacklist.txt $server
		mv $backupdir/query_ip_whitelist.txt $server
		mv $backupdir/ts3server.ini $server
		mv $backupdir/ts3db_mariadb.ini $server
		mv $backupdir/ts3server.sqlitedb $server
		echo $Version > $server/version
		echo "Starting Updated Server"
		systemctl start ts3
		;;
    (-U) 
    echo "Stopping TS3 Server"
		systemctl stop ts3
		echo "Running Backup of Settings and DB of TeamSpeak Server Before Update"
		cp $server/query_ip_blacklist.txt $backupdir
		cp $server/query_ip_whitelist.txt $backupdir
		cp $server/ts3server.ini $backupdir
		cp $server/ts3db_mariadb.ini $backupdir
		cp $server/ts3server.sqlitedb $backupdir
		echo "Downloading Latest Version of TeamSpeak 3 Server"
		wget -nv http://teamspeak.gameserver.gamed.de/ts3/releases/$Version/teamspeak3-server_linux_$arch-$Version.tar.bz2 --output-document=$dl/package.tar.bz2
		echo "Installing TS3 Server Version $Version"
		tar -xjf $dl/package.tar.bz2 -C $dl/
		cp -rf $dl/teamspeak3-server_linux_$arch/* $server
		rm $dl/package.tar.bz2
		echo "Moving back Settings and DB back to TS3 Folder"
		mv $backupdir/query_ip_blacklist.txt $server
		mv $backupdir/query_ip_whitelist.txt $server
		mv $backupdir/ts3server.ini $server
		mv $backupdir/ts3db_mariadb.ini $server
		mv $backupdir/ts3server.sqlitedb $server
		echo $Version > $server/version
		echo "Starting Updated Server"
		systemctl start ts3
    ;;
    (-*) echo "Invalid Argument"; exit 0;;
esac
exit 0
