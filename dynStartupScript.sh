#!/bin/sh

# Summary:
# This script is a one stop installing and maintenance script for Dynamic. 
# It is used to startup a new VPS. It will download, compile, and maintain the wallet.

# Credit:
# Written by those who are dedicated to teaching other about ion (ionomy.com) and other cryptocurrencies. 
# Contributors:         DYN Donation Address
#   LordDarkHelmet      D9HWH96iQDX5W4LFag7v8pUtQgnWUHGFLo
#   Broyhill            DQDAmUJKGyErmgVHSnSkVrrzssz3RedW2V

# Version:
varVersion="1.0.3 dynStartupScript.sh April 10, 2017 Released by LordDarkHelmet"
echo "$varVersion"
echo "Original Version found at: https://github.com/LordDarkHelmet/DynamicScripts"
echo "If you found this script usefull please contribute. Feedback is appreciated"

# The script was tested using on Vultr. Umbuntu 14.04 x64, 1 CPU, 512 MB ram, 20 GB SSD, 500 GB bandwith
# LordDarkHelmet's affiliate link: http://www.vultr.com/?ref=6923886-3B
# 
# If you are using Vultr as a VPN service and you run this in as your startup script, then you should see the results in /tmp/firstboot.log
# The script will take some time to run. You can view progress when you first log in by typing in the command:
# tail -f /tmp/firstboot.log

# Variables:
# These variables control the script's function. The only item you should change is the scrape address (the first variable)
#
# myScrapeAddress: This is the address that the wallet will scrape mining coins to:
# "CHANGE THE ADDRESS BELOW TO BE THE ONE FOR YOUR WALLET"
myScrapeAddress=DKCUXNLNLtm7AkUAraoRViX5HoJWmYVU1S
echo "We will be scraping to this address: $myScrapeAddress"
# "CHANGE THE ADDRESS ABOVE TO BE THE ONE FOR YOUR WALLET"

# Are you setting up a Dynode? if so you want to set these variables
# Set varDynode to 1 if you want to run a node, otherwise set it to zero. 
varDynode=0
# This will set the external IP to your IP adderess (linux only), or you can put your IP address in here
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
varQuickStart=true
varQuickBlockchainDownload=true
# Quickstart compressed file location and name
varQuickStartCompressedFileLocation=https://github.com/duality-solutions/Dynamic/releases/download/v1.3.0.1/Dynamic-Linux-x64-v1.3.0.1.tar.gz
varQuickStartCompressedFileName=Dynamic-Linux-x64-v1.3.0.1.tar.gz
varQuickStartCompressedFilePathForDaemon=dynamic-1.3.0/bin/dynamicd
varQuickStartCompressedFilePathForCLI=dynamic-1.3.0/bin/dynamic-cli
varQuickStartCompressedBlockChainLocation=http://108.61.216.160/cryptochainer.chains/chains/Dynamic_blockchain.zip
varQuickStartCompressedBlockChainFileName=Dynamic_blockchain.zip
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

#GIT
varRemoteRepository=https://github.com/duality-solutions/Dynamic

#
#End of Variables

### Prep your VPS (Increase Swap Space and update) ###

if [ "$varExpandSwapFile" = true ]; then
# This will expand your swap file. It is not necessary if your VPS has more than 3G of ram, but it wont hurt to have
echo "Expanding the swap file for optimization with low RAM VPS..."
sudo fallocate -l 3G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# the following command will append text to fstab to make sure your swap file stays there even after a reboot.
echo "/swapfile none swap sw 0 0" >> /etc/fstab
echo "Swap file expanded."
fi

# Ensure that your system is up to date and fully patched
echo "Updating OS and packages..."
sudo apt-get update && sudo apt-get -y upgrade

## make the directories we are going to use
mkdir -p $varDynamicBinaries
mkdir -p $varScriptsDirectory


## Create Scripts ##
mkdir -p $varScriptsDirectory

### Script #1: Stop dynamicd ###
# Filename dynStopDynamicd.sh
cd $varScriptsDirectory
echo "Creating The Stop dynamicd Script: dynStopDynamicd.sh"
echo '#!/bin/sh' > dynStopDynamicd.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> dynStopDynamicd.sh
echo "# This script is here to force stop or force kill dynamicd" >> dynStopDynamicd.sh
echo "cd $varDynamicBinaries" >> dynStopDynamicd.sh
echo "echo \"Stopping the dynamicd if it already running \"" >> dynStopDynamicd.sh
echo "# stop the dynamic daemon if it is running" >> dynStopDynamicd.sh
echo "sudo ./dynamic-cli stop" >> dynStopDynamicd.sh
echo "sleep 5" >> dynStopDynamicd.sh
echo "# Killing the daemon and relaunching with the generated dynamic.conf (for RPC control). This is the only way to relaunch it at this point." >> dynStopDynamicd.sh
echo "PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynStopDynamicd.sh
echo "if [ \"\" !=  \"\$PID\" ]; then" >> dynStopDynamicd.sh
echo "  sudo kill -9 \$PID" >> dynStopDynamicd.sh
echo "fi" >> dynStopDynamicd.sh
echo "sleep 1" >> dynStopDynamicd.sh
echo "echo \"Stop Complete\"" >> dynStopDynamicd.sh
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
echo "myZero=0.0" >> dynScrape.sh
echo "myBalance=\$(sudo ${varDynamicBinaries}dynamic-cli getbalance)" >> dynScrape.sh
echo "if [  -gt \$myZero ];then" >> dynScrape.sh
echo "echo\"\$(date +%F_%T) Scraping a balance of \myBalance to $myScrapeAddress \"" >> dynScrape.sh
echo "sudo ${varDynamicBinaries}dynamic-cli sendtoaddress \"$myScrapeAddress\" \$(sudo ${varDynamicBinaries}dynamic-cli getbalance) \"\" \"\" true " >> dynScrape.sh
echo "fi" >> dynScrape.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynScrape.sh
echo "Created dynScrape.sh."


### script #3: GENERATE SCRAPE SCRIPT ###
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
 echo "Creating the dynamic.conf file, this replaces any existing file. "
 
 Myrpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
 Myrpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
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

 if [[ "$varDynode" -eq 1 ]]; then
  echo "# DYNODE: " >> $varDynamicConfigFile
  echo "externalip=$varDynodeExternalIP" >> $varDynamicConfigFile
  echo "dynode=$varDynode" >> $varDynamicConfigFile
  echo "dynodeprivkey=$varDynodePrivateKey" >> $varDynamicConfigFile
  echo "" >> $varDynamicConfigFile
 fi

 echo "# End of generated file" >> $varDynamicConfigFile
 echo "Finished creating dynamic.conf"
}



####### RESERVED For Security Lockdown Function #############
#Perminant lockdown and security of the node/miner. Not implementing before we work out the bugs. (dont want to lock us out from debugging it)
####### RESERVED For Security Lockdown Function #############



## Quick Start (get blockchain from the web, not completly safe or reliable, but fast!)
if [ "$varQuickBlockchainDownload" = true ]; then

echo "If the dynamicd process is running, this will kill it."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

mkdir -p /root/QuickStart
cd /root/QuickStart

echo "Downloading blockchain bootstrap and extracting to data folder..."
sudo apt-get -y install unzip
rm -fdr $varQuickStartCompressedBlockChainFileName
wget $varQuickStartCompressedBlockChainLocation
mkdir -p $varDynamicConfigDirectory
unzip -o $varQuickStartCompressedBlockChainFileName -d $varDynamicConfigDirectory
echo "Finished blockchain download and extraction"

fi


## Quick Start (get binaries from the web, not completly safe or reliable, but fast!)
if [ "$varQuickStart" = true ]; then
echo "Begining QuickStart"

echo "If the dynamicd process is running, this will kill it."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

mkdir -p /root/QuickStart
cd /root/QuickStart
echo "Downloading and extracting Dynamic binaries"
rm -fdr $varQuickStartCompressedFileName
wget $varQuickStartCompressedFileLocation
tar -xzf $varQuickStartCompressedFileName

echo "Copy QuickStart binaries"
mkdir -p $varDynamicBinaries
sudo cp $varQuickStartCompressedFilePathForDaemon $varDynamicBinaries
sudo cp $varQuickStartCompressedFilePathForCLI $varDynamicBinaries

echo "Launching daemon for the first time. Please wait a minute while the wallet.dat, dynamic.conf, and any other files missing from .dynamic home data directory are generated."
sudo ${varDynamicBinaries}dynamicd --daemon
sleep 60

echo "Killing the daemon and relaunching with the generated dynamic.conf (for RPC control). This is the only way to relaunch it at this point."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

echo "Ok, now we are going to modify the dynamic.conf file so that when you boot up dynamicd, you will be mining. no ned to invoke dynamic-cli setgenerate true"
funcCreateDynamicConfFile

echo "Start up the dynamic daemon. A full sync can take many hours. Mining will automatically start once synced."
sudo ${varDynamicBinaries}dynamicd --daemon
echo "waiting 60 seconds"
sleep 60
echo "Dynamic Wallet created and blockchain should be syncing."

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
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev automake libminiupnpc-dev libgmp-dev libboost-all-dev
sudo add-apt-repository -y ppa:silknetwork/silknetwork
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev 

# Clone the github repository
echo "Clone the github repository"
cd $varGITRootPath
sudo git clone $varRemoteRepository
echo "Pull changes from the github repository. If they update the code, this will bring your code up to date. "
cd $varGITDynamicPath
sudo git pull $varRemoteRepository

# Compile the Daemon Client
echo "Compile the Daemon Client"
cd $varGITDynamicPath
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make install
echo "Compile Finished."

echo "If the dynamicd process is running, this will kill it."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

echo "Copy compiled binaries, if you used QuickStart your binaries are being replaced by the compiled ones"
mkdir -p $varDynamicBinaries
sudo cp ${varGITDynamicPath}src/dynamicd $varDynamicBinaries
sudo cp ${varGITDynamicPath}src/dynamic-cli $varDynamicBinaries

echo "Launching daemon for the first time. Please wait a minute while the wallet.dat, dynamic.conf, and any other files missing from .dynamic home data directory are generated."
sudo ${varDynamicBinaries}dynamicd --daemon
sleep 60

echo "Killing the daemon and relaunching with the generated dynamic.conf (for RPC control). This is the only way to relaunch it at this point."
sudo ${varScriptsDirectory}dynStopDynamicd.sh

echo "Ok, now we are going to modify the dynamic.conf file so that when you boot up dynamicd, you will be mining. no ned to invoke dynamic-cli setgenerate true"
funcCreateDynamicConfFile

echo "Start up the dynamic daemon. A full sync can take many hours. Mining will automatically start once synced."
sudo ${varDynamicBinaries}dynamicd --daemon
echo "waiting 60 seconds"
sleep 60
echo "Dynamic Wallet created and blockchain should be syncing."


## CREATE CRON JOBS ###
echo "Creating Boot Start and Scrape Cron jobs..."

dynStart="${varScriptsDirectory}dynMineStart.sh"
dynScrape="${varScriptsDirectory}dynScrape.sh"
dynAutoUpdater="${varScriptsDirectory}dynAutoUpdater.sh"

startLine="@reboot sh $dynStart >> ${varScriptsDirectory}/dynMineStart.log 2>&1"
scrapeLine="*/$varMiningScrapeTime * * * * $dynScrape >> ${varScriptsDirectory}/dynScrape.log 2>&1"

#we don't want eveyone updating at the same time, that would be bad for the network, so check for updates at a random time.
AutoUpdaterLine="$(( $RANDOM % 59 )) $(( $RANDOM % 23 )) * * * $dynAutoUpdater >> ${varScriptsDirectory}/dynAutoUpdater.log 2>&1"
#this will check once a day, just at a random time of day from other runs of this script. 

(crontab -u root -l 2>/dev/null | grep -v -F "$dynStart"; echo "$startLine") | crontab -u root -
(crontab -u root -l 2>/dev/null | grep -v -F "$dynScrape"; echo "$scrapeLine") | crontab -u root -
(crontab -u root -l 2>/dev/null | grep -v -F "$dynAutoUpdater"; echo "$AutoUpdaterLine") | crontab -u root -


############### We want to give the dynode priv key thing
##dynamic -cli dynode genkey


echo "Created Cron jobs.
All set! Helpful commands:
\"dynamic-cli getmininginfo\" to check mining and # of blocks synced.
\"dynamic-cli stop\" stops and \"dynamicd --daemon\" starts.
\"dynamic-cli setgenerate true\" to start mining.
\"dynamic-cli listaddressgroupings to see mined balances.
\"dynamic-cli help\" for a full list of commands.

 Version: $varVersion
end of startup script"
