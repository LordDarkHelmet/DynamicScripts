#!/bin/sh

# Summary:
# This script is a one stop installing and maintenance script for Dynamic. 
# It is used to startup a new VPS. It will download, compile, and maintain the wallet.

# myScrapeAddress: This is the address that the wallet will scrape mining coins to:
# "IF YOU DON'T USE ATTRIBUTES TO PASS IN YOUR VALUES THEN:"
# "CHANGE THE ADDRESS BELOW TO BE THE ONE FOR YOUR WALLET"
myScrapeAddress=DJnERexmBy1oURgpp2JpzVzHcE17LTFavD
# "CHANGE THE ADDRESS ABOVE TO BE THE ONE FOR YOUR WALLET"
# "CHANGE THE ADDRESS ABOVE TO BE THE ONE FOR YOUR WALLET"

# Credit:
# Written by those who are dedicated to teaching other about ion (ionomy.com) and other cryptocurrencies. 
# Contributors:         DYN Donation Address                      BTC Address
#   LordDarkHelmet      DJnERexmBy1oURgpp2JpzVzHcE17LTFavD        1NZya3HizUdeJ1CNbmeJEW3tHkXUG6PoNn
#   Broyhill            DQDAmUJKGyErmgVHSnSkVrrzssz3RedW2V
#   Coinkiller          DLvnNNYzbUxtDyADbyGDSio9ghazEcvRBk
#   Your name here, help add value by contributing. Contanct LordDarkHelmet on Github!

# Version:
varVersion="1.0.14 dynStartupScript.sh April 20, 2017 Released by LordDarkHelmet"

# The script was tested using on Vultr. Umbuntu 14.04 x64, 1 CPU, 512 MB ram, 20 GB SSD, 500 GB bandwith
# LordDarkHelmet's affiliate link: http://www.vultr.com/?ref=6923885
# 
# If you are using Vultr as a VPN service and you run this in as your startup script, then you should see the results in /tmp/firstboot.log
# The script will take some time to run. You can view progress when you first log in by typing in the command:
# tail -f /tmp/firstboot.log

echo ""
echo ""
echo "==========================================================================="
echo "$varVersion"
echo "Original Version found at: https://github.com/LordDarkHelmet/DynamicScripts"
echo "Local Filename: $0"
echo "Local Time: $(date +%F_%T)"
echo "If you found this script useful please contribute. Feedback is appreciated"
echo "==========================================================================="

# Variables:
# These variables control the script's function. The only item you should change is the scrape address (the first variable, see above)
#

# Are you setting up a Dynode? if so you want to set these variables
# Set varDynode to 1 if you want to run a node, otherwise set it to zero. 
varDynode=0
# This will set the external IP to your IP address (linux only), or you can put your IP address in here
varDynodeExternalIP=$(hostname -I)
# This is your dynode private key. To get it run dynamic-cli dynode genkey
varDynodePrivateKey=ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey

# Location of Dynamic Binaries, GIT Directories, and other useful files
# Do not use the GIT directory (/Dynamic/) for anyting other than GIT stuff
varUserDirectory=/root/
varDynamicBinaries="${varUserDirectory}DYN/bin/"
varScriptsDirectory="${varUserDirectory}DYN/UserScripts/"
varDynamicConfigDirectory="${varUserDirectory}.dynamic/"
varDynamicConfigFile="${varUserDirectory}.dynamic/dynamic.conf"
varGITRootPath="${varUserDirectory}"
varGITDynamicPath="${varGITRootPath}Dynamic/"

# Quick Non-Source Start (get binaries and blockchain from the web, not completly safe or reliable, but fast!)

# QuickStart Binaries
varQuickStart=true
# Quickstart compressed file location and name
varQuickStartCompressedFileLocation=https://github.com/duality-solutions/Dynamic/releases/download/v1.3.0.2/Dynamic-Linux-x64-v1.3.0.2.tar.gz
varQuickStartCompressedFileName=Dynamic-Linux-x64-v1.3.0.2.tar.gz
varQuickStartCompressedFilePathForDaemon=dynamic-1.3.0/bin/dynamicd
varQuickStartCompressedFilePathForCLI=dynamic-1.3.0/bin/dynamic-cli

# QuickStart Bootstrap (The developer recomends that you set this to true. This will clean up the blockchain on the network.)
varQuickBootstrap=true
varQuickStartCompressedBootstrapLocation=http://dyn.coin-info.net/bootstrap/bootstrap-2017-04-17_11-00\(UTC\).tar.gz
varQuickStartCompressedBootstrapFileName=bootstrap-2017-04-17_11-00\(UTC\).tar.gz
varQuickStartCompressedBootstrapFileIsZip=false

# QuickStart Blockchain (Downloading the blockchain will save time. It is up to you if you want to take the risk.)
varQuickBlockchainDownload=false
varQuickStartCompressedBlockChainLocation=http://108.61.216.160/cryptochainer.chains/chains/Dynamic_blockchain.zip
varQuickStartCompressedBlockChainFileName=Dynamic_blockchain.zip
varQuickStartCompressedBlockChainFileIsZip=true


#
#Expand Swap File
varExpandSwapFile=true

#Mining Variables
#varMining0ForNo1ForYes controls if we mine or not. set it to 0 if you don't want to mine, set to 1 if you want to mine
varMining0ForNo1ForYes=1
#varMiningProcessorLimit set the number of processors you want to use -1 for unbounded (all of them)
varMiningProcessorLimit=-1
#varMiningScrapeTime is the amount of time in minutes between scrapes use 15 recommended
varMiningScrapeTime=15

#Dynamic GIT
varRemoteRepository=https://github.com/duality-solutions/Dynamic

#Script Repository
#This can be used to auto heal and update the script system. 
#If a future deployment breaks something, an update by the repository owner can run a script on your machine. 
#This is dangerous becaus
varRemoteScriptRepository=https://github.com/LordDarkHelmet/DynamicScripts

#AutoUpdater
#This runs the auto update script. If you do not want to automatically update the script, then set this to false. If a new update 
varAutoUpdate=true

#AutoRepair
#Future Repair System. 
varAutoRepair=true

#System Lockdown
#Future System Lockdown. Firewall, security rules, etc. 
varSystemLockdown=true


#
#End of Variables


#Read in attributes. This allows someone to run the script with their variables without having to modify this script.
echo "-------------------------------------------"
echo "- This applies the values passed in by attributes"

while getopts :s:d:a:r:l: option
do
    case "${option}"
    in
        s) 
            myScrapeAddress=${OPTARG}
            echo "-s has set myScrapeAddress=${myScrapeAddress}"
            ;;
        d) 
            varDynodePrivateKey=${OPTARG}
            varDynode=1
            echo "-d has set varDynode=1, and has set varDynodePrivateKey=${varDynodePrivateKey}"
            ;;
        a)
            if [ "${OPTARG}" = true ]; then
                varAutoUpdate=true
                echo "-a has set varAutoUpdate to true (default)"
            else
                varAutoUpdate=false
                echo "-a has set varAutoUpdate to false, the system will not auto update. If an update occurs, you must do it manually."
            fi
            ;;
        r)
            if [ "${OPTARG}" = true ]; then
                varAutoRepair=true
                echo "Auto Repair is set to True (default)"
            else
                varAutoRepair=false
                echo "Auto Repair is set to FALSE, the system will not auto repair. If there is an issue you must repair it manually."
            fi
            ;;
        l)
            if [ "${OPTARG}" = true ]; then
                varSystemLockdown=true
                echo "Auto Lockdown is set to True (default)"
            else
                varSystemLockdown=false
                echo "Auto Lockdown is set to FALSE, the system will not be secured."
            fi
            ;;
        \?) echo "Invalid Option Tag: -$OPTARG";;
        :) echo "Option -$OPTARG requires an argument.";;
    esac
done

echo "-------------------------------------------"
echo "==============================================================="
echo "SCRAPE ADDRESS: $myScrapeAddress"
echo "==============================================================="
### Prep your VPS (Increase Swap Space and update) ###

if [ "$varExpandSwapFile" = true ]; then
    # This will expand your swap file. It is not necessary if your VPS has more than 4G of ram, but it wont hurt to have
    echo "Expanding the swap file for optimization with low RAM VPS..."
    sudo fallocate -l 4G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    # the following command will append text to fstab to make sure your swap file stays there even after a reboot.
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    echo "Swap file expanded."	
	
	echo "Current Swap File Status:"
	echo "sudo swapon -s"
	sudo swapon -s
	echo ""
	echo "Let's check the memory"
	echo ""
	echo "free -m"
	free -m
	echo ""
	echo "Ok, now let's check the swapieness"
	echo "cat /proc/sys/vm/swappiness"
	cat /proc/sys/vm/swappiness
	echo ""
	echo "Desktops usually have a swapieness of 60 or so, VPS's are usually lower. It should not matter for this application. It is just a curiosity."
	echo "End of Swap File expantion"
	echo "-------------------------------------------"
fi

# Ensure that your system is up to date and fully patched
echo ""
echo "Updating OS and packages..."
echo "sleeping for 60 seconds, this is because some VPS's are not fully up if you use this as a startup script"
sleep 60
echo "sudo apt-get update"
sudo apt-get update
echo "sudo apt-get -y upgrade"
sudo apt-get -y upgrade
echo "OS and packages updated."
echo ""

## make the directories we are going to use
mkdir -p $varDynamicBinaries
mkdir -p $varScriptsDirectory


## Create Scripts ##
echo "-------------------------------------------"
echo "Create the scripts we are going to use: "
mkdir -p $varScriptsDirectory

### Script #1: Stop dynamicd ###
# Filename dynStopDynamicd.sh
cd $varScriptsDirectory
echo "Creating The Stop dynamicd Script: dynStopDynamicd.sh"
echo '#!/bin/sh' > dynStopDynamicd.sh
echo "# This file was generated.  Version: $varVersion" >> dynStopDynamicd.sh
echo "# This script is here to force stop or force kill dynamicd" >> dynStopDynamicd.sh
echo "cd $varDynamicBinaries" >> dynStopDynamicd.sh
echo "echo \"Stopping the dynamicd if it already running \"" >> dynStopDynamicd.sh
echo "# stop the dynamic daemon if it is running" >> dynStopDynamicd.sh
echo "sudo ./dynamic-cli stop" >> dynStopDynamicd.sh
echo "sleep 15" >> dynStopDynamicd.sh
echo "# Kill the process directly, if it could not be shut down normally." >> dynStopDynamicd.sh
echo "PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynStopDynamicd.sh
echo "if [ \"\" !=  \"\$PID\" ]; then" >> dynStopDynamicd.sh
echo "  echo \"Rouge dynamicd process found. Killing PID: \$PID\""  >> dynStopDynamicd.sh
echo "  sudo kill -9 \$PID" >> dynStopDynamicd.sh
echo "fi" >> dynStopDynamicd.sh
echo "sleep 1" >> dynStopDynamicd.sh
echo "echo \"Stop Complete\"" >> dynStopDynamicd.sh
echo "sleep 1" >> dynStopDynamicd.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynStopDynamicd.sh
echo "Created dynStopDynamicd.sh"

### Script #2: MINING START SCRIPT ###
# Filename dynMineStart.sh
cd $varScriptsDirectory
echo "Creating Mining Start script: dynMineStart.sh"
echo '#!/bin/sh' > dynMineStart.sh
echo "" >> dynMineStart.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> dynMineStart.sh
echo "echo \"Starting Dynamic miner: \$(date)\"" >> dynMineStart.sh
echo "sudo ${varDynamicBinaries}dynamicd --daemon" >> dynMineStart.sh
echo "sleep 15" >> dynMineStart.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynMineStart.sh
echo "Created dynMineStart.sh."

### script #3: GENERATE SCRAPE SCRIPT ###
# Filename: dynScrape.sh
cd $varScriptsDirectory
echo "Creating Scrape script: dynScrape.sh"
echo '#!/bin/sh' > dynScrape.sh
echo "" >> dynScrape.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> dynScrape.sh
echo "" >> dynScrape.sh
echo "myBalance=\$(sudo ${varDynamicBinaries}dynamic-cli getbalance)" >> dynScrape.sh
echo "if [ \$myBalance != \"0.00000000\" ];then" >> dynScrape.sh
echo "echo \"\$(date +%F_%T) Scraping a balance of \$myBalance to $myScrapeAddress \"" >> dynScrape.sh
echo "sudo ${varDynamicBinaries}dynamic-cli sendtoaddress \"$myScrapeAddress\" \$(sudo ${varDynamicBinaries}dynamic-cli getbalance) \"\" \"\" true " >> dynScrape.sh
echo "fi" >> dynScrape.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynScrape.sh
echo "Created dynScrape.sh."


### script #4: AUTO UPDATER SCRIPT ###
# Filename: dynAutoUpdater.sh
cd $varScriptsDirectory
echo "Creating Scrape script: dynAutoUpdater.sh"
echo '#!/bin/sh' > dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "cd $varGITDynamicPath" >> dynAutoUpdater.sh
echo "if [ \"\`git log --pretty=%H ...refs/heads/master^ | head -n 1\`\" = \"\`git ls-remote $varRemoteRepository -h refs/heads/master |cut -f1\`\" ] ; then " >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : We are up to date.\" " >> dynAutoUpdater.sh
echo "else" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Changes to the repository, Preparing to update.\" " >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 1. Download the new source code from the repository if it has been updated" >> dynAutoUpdater.sh
echo " cd $varGITDynamicPath" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Downloading changes to the source code\" " >> dynAutoUpdater.sh
echo " sudo git pull $varRemoteRepository" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 2. Compile the new code" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Compile the souce code\"" >> dynAutoUpdater.sh
echo " cd $varGITDynamicPath" >> dynAutoUpdater.sh
echo " sudo ./autogen.sh" >> dynAutoUpdater.sh
echo " sudo ./configure" >> dynAutoUpdater.sh
echo " sudo make" >> dynAutoUpdater.sh
echo " sudo make install" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Compile Finished.\"" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 3. Stop the running daemon" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Stop the running daemon.\"" >> dynAutoUpdater.sh
echo " sudo ${varScriptsDirectory}dynStopDynamicd.sh" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 4. Replace the executable files" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Replace the executable files.\"" >> dynAutoUpdater.sh
echo " mkdir -p $varDynamicBinaries" >> dynAutoUpdater.sh
echo " sudo cp ${varGITDynamicPath}src/dynamicd $varDynamicBinaries" >> dynAutoUpdater.sh
echo " sudo cp ${varGITDynamicPath}src/dynamic-cli $varDynamicBinaries" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 5. Start the daemon" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Start the daemon. Mining will automatically start once synced.\"" >> dynAutoUpdater.sh
echo " sudo ${varDynamicBinaries}dynamicd --daemon" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " echo "waiting 10 seconds"" >> dynAutoUpdater.sh
echo " sleep 10" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Now running the latest GIT version.\"" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "fi" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynAutoUpdater.sh
echo "Created dynAutoUpdater.sh."

######## Reserverd for Watchdog #############
# Not implementing for now. Dont want to mask potential issues witht he script by keeping the daemon on life support. 
######## Reserverd for Watchdog #############




### Functions ###

funcCreateDynamicConfFile ()
{
 echo "---------------------------------"
 echo "- Creating the configuration file."
 echo "- Creating the dynamic.conf file, this replaces any existing file. "
 echo "Need to crate a random password and user name. Check current entropy"
 sudo cat /proc/sys/kernel/random/entropy_avail

 sleep 1
 Myrpcuser=$(sudo tr -d -c "a-zA-Z0-9" < /dev/urandom | sudo head -c 34)
 echo "Myrpcuser=$Myrpcuser"
 sleep 1
 Myrpcpassword=$(sudo tr -d -c "a-zA-Z0-9" < /dev/urandom | sudo head -c $(shuf -i 30-36 -n 1))
 echo "Myrpcpassword=$Myrpcpassword"
 Myrpcport=$(shuf -i 50000-65000 -n 1)
 Myport=$(shuf -i 1-500 -n 1)
 Myport=$((Myrpcport+Myport))
 
 mkdir -p $varDynamicConfigDirectory
 echo "# This file was generated. $(date +%F_%T)  Version: $varVersion" > $varDynamicConfigFile
 echo "# Do not use special characters or spaces with username/password" >> $varDynamicConfigFile
 echo "rpcuser=$Myrpcuser" >> $varDynamicConfigFile
 echo "rpcpassword=$Myrpcpassword" >> $varDynamicConfigFile
 echo "rpcport=31350" >> $varDynamicConfigFile
 echo "port=31300" >> $varDynamicConfigFile
 echo "" >> $varDynamicConfigFile
 echo "# MINIMG:  These are your mining variables" >> $varDynamicConfigFile
 echo "# Gen can be 0 or 1. 1=mining, 0=No mining" >> $varDynamicConfigFile
 echo "gen=$varMining0ForNo1ForYes" >> $varDynamicConfigFile
 echo "# genproclimit sets the number of processors you want to use -1 for unbounded (all of them)" >> $varDynamicConfigFile
 echo "genproclimit=$varMiningProcessorLimit" >> $varDynamicConfigFile
 echo "" >> $varDynamicConfigFile

 if [ "$varDynode" = 1 ]; then
  echo "# DYNODE: " >> $varDynamicConfigFile
  echo "externalip=$varDynodeExternalIP" >> $varDynamicConfigFile
  echo "dynode=$varDynode" >> $varDynamicConfigFile
  echo "dynodeprivkey=$varDynodePrivateKey" >> $varDynamicConfigFile
  echo "" >> $varDynamicConfigFile
 fi

 echo "# End of generated file" >> $varDynamicConfigFile
 echo "- Finished creating dynamic.conf"
 echo "---------------------------------"
 sleep 1
}



####### RESERVED For Security Lockdown Function #############
#Perminant lockdown and security of the node/miner. Not implementing before we work out the bugs. (dont want to lock us out from debugging it)
####### RESERVED For Security Lockdown Function #############



## Quick Start Get Botstrap Data, recomended by the development team.
if [ "$varQuickBootstrap" = true ]; then
    echo "Starting Bootstrap and Blockchain download."
    echo "Step 1a: If the dynamicd process is running, Stop it"
    sudo ${varScriptsDirectory}dynStopDynamicd.sh

    echo "Step 1b: Backup wallet.dat files"
    #We are not backing up the full data directory contrary to the instuctions. The reason is that this is most likely an automated situation and a backup will just waste space
    myBackupDirectory="${varScriptsDirectory}Backup$(date +%Y%m%d_%H%M%S)/"
    mkdir -p ${myBackupDirectory}backups/
    sudo cp -r ${varDynamicConfigDirectory}backups/* ${myBackupDirectory}backups/
    sudo cp ${varDynamicConfigDirectory}wallet.dat ${myBackupDirectory}
    sudo cp ${varDynamicConfigDirectory}dynamic.conf ${myBackupDirectory}
    echo "Files backed up to ${myBackupDirectory}"

    echo "Step 2: Delete all data apart from your wallet.dat, conf files and backup folder."
    rm -fdr $varDynamicConfigDirectory
    #we make sure the directory is there for the script.
    mkdir -p $varDynamicConfigDirectory

    echo "Step 3: Download the bootstrap.dat compressed file"

    mkdir -p ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."

    rm -fdr $varQuickStartCompressedBootstrapFileName
    mkdir -p $varDynamicConfigDirectory
    echo "wget $varQuickStartCompressedBootstrapLocation"
    wget $varQuickStartCompressedBootstrapLocation

    if [ $? -eq 0 ]; then
        echo "Download succeeded, extract ..."
        if [ "$varQuickStartCompressedBootstrapFileIsZip" = true ]; then
            sudo apt-get -y install unzip
            unzip -o $varQuickStartCompressedBootstrapFileName -d $varDynamicConfigDirectory
            echo "Extracted Zip file ( $varQuickStartCompressedBootstrapFileName ) to the config directory ( $varDynamicConfigDirectory )"
        else
            tar -xvf $varQuickStartCompressedBootstrapFileName -C $varDynamicConfigDirectory
            echo "Extracted TAR file ( $varQuickStartCompressedBootstrapFileName ) to the config directory ( $varDynamicConfigDirectory )"
        fi
    else
        echo "Download of bootstrap failed. setting varQuickBootstrap=false"
	    varQuickBootstrap=false
	    echo "because the bootstrap failed, we are going to resort to downloading the blockchain"
	    varQuickBlockchainDownload=true
    fi

    echo "Step 4: Start Dynamic and import from bootstrap.dat. Daemon users need to use the \"-loadblock=\" argument when starting Dynamic"
    echo "We will complete this step later on in the setup file, either on download of the binaries, or on completion of the compelation if you don't download the binaries"
    sleep 1
    echo "Bootstrap Prep completed!"
    echo ""
fi


## blockchain download (get blockchain from the web, not completly safe or reliable, but fast!)

## Quick Start (get blockchain from the web, not completly safe or reliable, but fast!)
## If you are bootstraping, you can still download the blockchain. While the developers recomend you only bootstrap, this will save time while syncing.
## 
if [ "$varQuickBlockchainDownload" = true ]; then
    echo "Blockchain Download"
    echo "If the dynamicd process is running, this will kill it."
    sudo ${varScriptsDirectory}dynStopDynamicd.sh

    mkdir -p ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."
    sudo apt-get -y install unzip
    rm -fdr $varQuickStartCompressedBlockChainFileName
    wget $varQuickStartCompressedBlockChainLocation
    mkdir -p $varDynamicConfigDirectory

    if [ "$varQuickStartCompressedBlockChainFileIsZip" = true ]; then
        sudo apt-get -y install unzip
        unzip -o $varQuickStartCompressedBlockChainFileName -d $varDynamicConfigDirectory
        echo "Extracted Zip file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varDynamicConfigDirectory )"
    else
        tar -xvf $varQuickStartCompressedBlockChainFileName -C $varDynamicConfigDirectory
        echo "Extracted TAR file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varDynamicConfigDirectory )"
    fi

    echo "Finished blockchain download and extraction"
    echo ""
fi

## Creating the config file. This prevents the boot up, have to shut down thing in dynamicd, We do this here just in case the quickstart stuff deletes the config file.
echo ""
echo "Ok, now we are going to modify the dynamic.conf file so that when you boot up dynamicd, you will be mining. no ned to invoke dynamic-cli setgenerate true"
funcCreateDynamicConfFile
echo "Now that we have crated the dynamic.conf file, there is no need to do the boot up shut down thing with dyanmicd"
echo ""


## Quick Start (get binaries from the web, not completly safe or reliable, but fast!)
if [ "$varQuickStart" = true ]; then
echo "Begining QuickStart Executable (binaries) download and start"

echo "If the dynamicd process is running, this will kill it."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

mkdir -p ${varUserDirectory}QuickStart
cd ${varUserDirectory}QuickStart
echo "Downloading and extracting Dynamic binaries"
rm -fdr $varQuickStartCompressedFileName
wget $varQuickStartCompressedFileLocation
tar -xzf $varQuickStartCompressedFileName

echo "Copy QuickStart binaries"
mkdir -p $varDynamicBinaries
sudo cp $varQuickStartCompressedFilePathForDaemon $varDynamicBinaries
sudo cp $varQuickStartCompressedFilePathForCLI $varDynamicBinaries


echo "Launching daemon for the first time."
if [ "$varQuickBootstrap" = true ]; then
  echo "sudo ${varDynamicBinaries}dynamicd --daemon -loadblock=${varDynamicConfigDirectory}bootstrap.dat"
  sudo ${varDynamicBinaries}dynamicd --daemon -loadblock=${varDynamicConfigDirectory}bootstrap.dat 
else
  echo "sudo ${varDynamicBinaries}dynamicd --daemon"
  sudo ${varDynamicBinaries}dynamicd --daemon
fi

echo "Waiting 60 seconds"
sleep 60

echo "The Daemon has started. We are currently on Block:"
echo "sudo ${varDynamicBinaries}dynamic-cli getblockcount"
sudo ${varDynamicBinaries}dynamic-cli getblockcount
echo "A full sync can take many hours. Mining will automatically start once synced."
sleep 1

echo ""
echo "In case Compiling later on fails, we want to put all of our cron jobs in"
echo ""

## CREATE CRON JOBS ###
echo "Creating Boot Start and Scrape Cron jobs..."

dynStart="${varScriptsDirectory}dynMineStart.sh"
dynScrape="${varScriptsDirectory}dynScrape.sh"

startLine="@reboot sh $dynStart >> ${varScriptsDirectory}dynMineStart.log 2>&1"
scrapeLine="*/$varMiningScrapeTime * * * * $dynScrape >> ${varScriptsDirectory}dynScrape.log 2>&1"

(crontab -u root -l 2>/dev/null | grep -v -F "$dynStart"; echo "$startLine") | crontab -u root -
(crontab -u root -l 2>/dev/null | grep -v -F "$dynScrape"; echo "$scrapeLine") | crontab -u root -

echo "Boot Start and Scrape Cron jobs created"

echo "QuickStart complete"
fi
#End of QuickStart

#Ok If you did a QuickStart, we are going to build a new wallet. 
#This will happen while you are mining, so it will take super long, but you don't care.
#when we complete the build we will stop the miner, replace the binary, and continue.  

# Install Dependencies and other tools
echo "Install Dependencies and other tools"
sudo apt-get -y install software-properties-common python-software-properties 
sudo add-apt-repository -y ppa:git-core/ppa 
sudo apt-get -y update 
sudo apt-get -y install nano
sudo apt-get -y install git
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config bsdmainutils libssl-dev libcrypto++-dev libevent-dev automake libminiupnpc-dev libgmp-dev libboost-all-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo add-apt-repository -y ppa:silknetwork/silknetwork
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
sudo apt-get -y update
sudo apt-get -y upgrade

# Clone the github repository
echo "Clone the github repository"
cd $varGITRootPath
sudo git clone $varRemoteRepository
echo "Pull changes from the github repository. If they update the code, this will bring your code up to date. "
cd $varGITDynamicPath
sudo git pull $varRemoteRepository

# Compile the Daemon Client
echo "-------------------------------------------"
echo "Compile the Daemon Client"
cd $varGITDynamicPath
echo "-----------------"
echo "sudo ./autogen.sh"
sudo ./autogen.sh
echo "-----------------"
echo "sudo ./configure"
sudo ./configure
echo "-----------------"
echo "sudo make"
sudo make
echo "-----------------"
echo "sudo make install"
sudo make install
echo "Compile Finished."
echo "-------------------------------------------"

echo "If the dynamicd process is running, this will kill it."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

echo "Copy compiled binaries, if you used QuickStart your binaries are being replaced by the compiled ones"
mkdir -p $varDynamicBinaries
sudo cp ${varGITDynamicPath}src/dynamicd $varDynamicBinaries
sudo cp ${varGITDynamicPath}src/dynamic-cli $varDynamicBinaries

if [ "$varQuickBootstrap" = true ]; then

  if [ "$varQuickStart" = true ]; then
     echo "skipping the pre-launch because we already did it with the quickstart"
	 echo "sudo ${varDynamicBinaries}dynamicd --daemon"
	 sudo ${varDynamicBinaries}dynamicd --daemon
  else
    echo "Doing the bootstrap from step 4 here because we want to boot strap"
	echo "sudo ${varDynamicBinaries}dynamicd --daemon -loadblock=${varDynamicConfigDirectory}bootstrap.dat"
    sudo ${varDynamicBinaries}dynamicd --daemon -loadblock=${varDynamicConfigDirectory}bootstrap.dat
  fi
else
  echo "sudo ${varDynamicBinaries}dynamicd --daemon"
  sudo ${varDynamicBinaries}dynamicd --daemon
fi

echo "waiting 60 seconds"
sleep 60

echo "The Daemon has started. We are currently on Block:"
echo "sudo ${varDynamicBinaries}dynamic-cli getblockcount"
sudo ${varDynamicBinaries}dynamic-cli getblockcount
echo "A full sync can take many hours. Mining will automatically start once synced."
sleep 1

echo "Dynamic Wallet created and blockchain should be syncing."


## CREATE CRON JOBS ###
echo "-------------------------------------------"
echo "Creating Boot Start and Scrape Cron jobs..."

dynStart="${varScriptsDirectory}dynMineStart.sh"
dynScrape="${varScriptsDirectory}dynScrape.sh"
dynAutoUpdater="${varScriptsDirectory}dynAutoUpdater.sh"

startLine="@reboot sh $dynStart >> ${varScriptsDirectory}dynMineStart.log 2>&1"
scrapeLine="*/$varMiningScrapeTime * * * * $dynScrape >> ${varScriptsDirectory}dynScrape.log 2>&1"

(crontab -u root -l 2>/dev/null | grep -v -F "$dynStart"; echo "$startLine") | crontab -u root -
(crontab -u root -l 2>/dev/null | grep -v -F "$dynScrape"; echo "$scrapeLine") | crontab -u root -

if [ "$varAutoUpdate" = true ]; then

  #we don't want eveyone updating at the same time, that would be bad for the network, so check for updates at a random time.
  AutoUpdaterLine="$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * $dynAutoUpdater >> ${varScriptsDirectory}dynAutoUpdater.log 2>&1"
  #this will check once a day, just at a random time of day from other runs of this script. 

  (crontab -u root -l 2>/dev/null | grep -v -F "$dynAutoUpdater"; echo "$AutoUpdaterLine") | crontab -u root -
  echo "Auto Update cron job has been set: ${AutoUpdaterLine}"
  echo "Auto Update will run once a day and automatically compile and execute new code if there have been commits to the remote repository."
  echo "Remote Repository: $varRemoteRepository"
else
  echo "Auto Update is set to false. We will not update if new code is updated in the repository: $varRemoteRepository"
fi


echo "Created cron jobs."
echo "-------------------------------------------"
echo "

===========================================================
All set! 
Helpful commands: 
\"dynamic-cli getmininginfo\" to check mining and # of blocks synced.
\"dynamicd --daemon\" starts the daemon.
\"dynamic-cli stop\" stops the daemon. 
\"dynamic-cli setgenerate true -1\" to start mining.
\"dynamic-cli listaddressgroupings\" to see mined balances.
\"dynamic-cli getblockcount\" gets the current blockcount
\"dynamic-cli gethashespersec\" gets your current hash rate.
\"dynamic-cli help\" for a full list of commands.

You may need to navigate to ${varDynamicBinaries} before you can run the commands. 
This command will navigate to ${varDynamicBinaries} the directory
cd ${varDynamicBinaries}

Alternitavly you can put the path (directory) before the command

example: Getting the blockcount:
sudo ${varDynamicBinaries}dynamic-cli getblockcount"
sudo ${varDynamicBinaries}dynamic-cli getblockcount
echo "
example: Getting the hash rate:
sudo ${varDynamicBinaries}dynamic-cli gethashespersec"
sudo ${varDynamicBinaries}dynamic-cli gethashespersec
echo "* note: hash rate may be 0 if the blockchain has not fully synced yet.

===========================================================

Version: $varVersion
end of startup script"
