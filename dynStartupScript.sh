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
#   Your name here, help add value by contributing. Contact LordDarkHelmet on Github!

# Version:
varVersion="1.0.19 dynStartupScript.sh May 5, 2017 Released by LordDarkHelmet"

# The script was tested using on Vultr. Ubuntu 14.04 & 16.04 x64, 1 CPU, 512 MB ram, 20 GB SSD, 500 GB bandwith
# LordDarkHelmet's affiliate link: http://www.vultr.com/?ref=6923885
# 
# If you are using Vultr as a VPN service and you run this in as your startup script, then you should see the results in /tmp/firstboot.log
# The script will take some time to run. You can view progress when you first log in by typing in the command:
# tail -f /tmp/firstboot.log


echo ""
echo "==========================================================================="
echo "$varVersion"
echo "Original Version found at: https://github.com/LordDarkHelmet/DynamicScripts"
echo "Local Filename: $0"
echo "Local Time: $(date +%F_%T)"
echo "System Info: $(uname -a)"
echo "User $(id -u -n)  UserID: $(id -u)"
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
# Do not use the GIT directory (/Dynamic/) for anything other than GIT stuff
varUserDirectory=/root/
varDynamicBinaries="${varUserDirectory}DYN/bin/"
varScriptsDirectory="${varUserDirectory}DYN/UserScripts/"
varDynamicConfigDirectory="${varUserDirectory}.dynamic/"
varDynamicConfigFile="${varUserDirectory}.dynamic/dynamic.conf"
varGITRootPath="${varUserDirectory}"
varGITDynamicPath="${varGITRootPath}Dynamic/"
varBackupDirectory="${varUserDirectory}DYN/Backups/"

# Quick Non-Source Start (get binaries and blockchain from the web, not completely safe or reliable, but fast!)

# QuickStart Binaries
varQuickStart=true
# Quickstart compressed file location and name
varQuickStartCompressedFileLocation=https://github.com/duality-solutions/Dynamic/releases/download/v1.3.0.2/Dynamic-Linux-x64-v1.3.0.2.tar.gz
varQuickStartCompressedFileName=Dynamic-Linux-x64-v1.3.0.2.tar.gz
varQuickStartCompressedFilePathForDaemon=dynamic-1.3.0/bin/dynamicd
varQuickStartCompressedFilePathForCLI=dynamic-1.3.0/bin/dynamic-cli

# QuickStart Bootstrap (The developer recommends that you set this to true. This will clean up the blockchain on the network.)
varQuickBootstrap=false
varQuickStartCompressedBootstrapLocation=http://dyn.coin-info.net/bootstrap/bootstrap-latest.tar.gz
varQuickStartCompressedBootstrapFileName=bootstrap-latest.tar.gz
varQuickStartCompressedBootstrapFileIsZip=false

# QuickStart Blockchain (Downloading the blockchain will save time. It is up to you if you want to take the risk.)
varQuickBlockchainDownload=true
varQuickStartCompressedBlockChainLocation=http://108.61.216.160/cryptochainer.chains/chains/Dynamic_blockchain.zip
varQuickStartCompressedBlockChainFileName=Dynamic_blockchain.zip
varQuickStartCompressedBlockChainFileIsZip=true

# Compile
# -varCompile will compile the code
varCompile=true


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
#This is dangerous and not implemented
varRemoteScriptRepository=https://github.com/LordDarkHelmet/DynamicScripts

#AutoUpdater
#This runs the auto update script. If you do not want to automatically update the script, then set this to false. If a new update 
varAutoUpdate=true

#AutoRepair
#Future Repair System. 
varAutoRepair=true
#Watchdog timer. Check every X min to see if we are still running. (5 min recommended)
varWatchdogTime=5
#Turn on or off the watchdog. default is true. 
varWatchdogEnabled=true

#System Lockdown
#Future System Lockdown. Firewall, security rules, etc. 
varSystemLockdown=true


#
#End of Variables


#
echo "-------------------------------------------"
echo "Read in attributes. This allows someone to run the script with their variables without having to modify this script."
echo ""
echo "To see all options pass in the -h attribute"
echo ""
echo "Options passed in: $@"
echo ""
while getopts :s:d:a:r:l:w:c:h option
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
            echo "-d has set varDynode=1, and has set varDynodePrivateKey=${varDynodePrivateKey} (the script will set up a dynode)"
            ;;
        a)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varAutoUpdate=true
                echo "-a has set varAutoUpdate to true (default), the system will auto update at a random time every 24 hours"
            else
                varAutoUpdate=false
                echo "-a has set varAutoUpdate to false, the system will not auto update. If an update occurs, you must do it manually."
            fi
            ;;
        r)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varAutoRepair=true
                echo "-r AUTO REPAIR NOT IMPLEMENTED YET, Auto Repair is set to True (default), the system will auto repair"
            else
                varAutoRepair=false
                echo "-r AUTO REPAIR NOT IMPLEMENTED YET, Auto Repair is set to FALSE, the system will not auto repair. If there is an issue you must repair it manually."
            fi
            ;;
        l)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varSystemLockdown=true
                echo "-l AUTO LOCKDOWN NOT IMPLEMENTED YET, Auto Lockdown is set to True (default), System will be secured"
            else
                varSystemLockdown=false
                echo "-l AUTO LOCKDOWN NOT IMPLEMENTED YET, Auto Lockdown is set to FALSE, the system will not be secured."
            fi
			;;
        w)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varWatchdogEnabled=true
                echo "-w varWatchdogEnabled is set to true (default), Watchdog will check every $varWatchdogTime min to see if dynamicd is still running"
            else
                varWatchdogEnabled=false
                echo "-w varWatchdogEnabled is set to false, Watchdog will be disabled"
            fi
            ;;
        c)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = true ]; then
                varCompile=true
                echo "-w varCompile is set to true (default), We will compile the code"
            else
                varCompile=false
                echo "-w varCompile is set to false, We will not compile"
                varAutoUpdate=false
                echo "   varAutoUpdate is also set to false because it requires compiling"
            fi
            ;;
        h)
            echo ""
			echo "Help:"
			echo "This script, $0 , can use the following attributes:"
            echo " -s Scrape address requires an attribute Ex.  -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
            echo " -d Dynode Private key. if you populate this it will setup a dynode.  ex -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey"
            echo " -a Auto Updates. Turns auto updates (on by default) on or off, ex -a true"
            echo " -r Auto Repair. Turn auto repair on (default) or off, ex -r true"
            echo " -l System Lockdown. (future) Secure the instance. True to lock down your system. ex -l false"
            echo " -w Watchdog. The watchdog restarts processes if they fail. true for on, false for off."
            echo " -c Compile. Compile the code, default is true. If you set it to false it will also turn off AutoUpdate"
            echo " -h Display Help then exit."
			echo ""
			echo "Example 1: Just set up a simple miner"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
			echo ""
			echo "Example 2: Setup a remote dynode"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey"
			echo ""
			echo "Example 3: Run a miner, but don't compile (auto update will be turned off by default), useful for low RAM VPS's that don't allow for SWAP files"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -c false"			
			echo ""
			echo "Example 4: Turn off auto update on a dynode, you will be required to manually update if a new version comes along"
			echo "sudo sh $0 -s DJnERexmBy1oURgpp2JpzVzHcE17LTFavD -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey -a false"
			echo ""			
			echo "sudo sh Example 5: Setup a miner that donates to the author's address DJnERexmBy1oURgpp2JpzVzHcE17LTFavD"
			echo "$0"
			echo ""			
			echo "PLEASE REMEMBER TO USE THE \"-s\" attribute. If you don't then you will be donating and not scraping to your address."
			echo ""
			echo ""
			exit 1
            ;;
        \?) echo "Invalid Option Tag: -$OPTARG";;
        :) echo "Option -$OPTARG requires an argument. Using Default Values and continuing.";;
    esac
done

echo "-------------------------------------------"
echo "==============================================================="
echo "SCRAPE ADDRESS: $myScrapeAddress"
echo "==============================================================="
echo "System Information:"
cat /etc/*release | grep -v URL
echo "If you found this script useful please contribute. Feedback is appreciated"
echo "==============================================================="


### Prep your VPS (Increase Swap Space and update) ###

if [ "$varExpandSwapFile" = true ]; then
    cd $varUserDirectory
    # This will expand your swap file. It is not necessary if your VPS has more than 4G of ram, but it wont hurt to have
    echo "Expanding the swap file for optimization with low RAM VPS..."
    echo "sudo fallocate -l 4G /swapfile"
	sudo fallocate -l 4G /swapfile
    echo "sudo chmod 600 /swapfile"
	sudo chmod 600 /swapfile
	echo "sudo mkswap /swapfile"
    sudo mkswap /swapfile
    echo "sudo swapon /swapfile"
	sudo swapon /swapfile

    # the following command will append text to fstab to make sure your swap file stays there even after a reboot.
	varSwapFileLine=$(cat /etc/fstab | grep "/swapfile none swap sw 0 0")
	if [  "varSwapFileLine" = "" ]; then
	    echo "Adding swap file line to /etc/fstab"
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
	else
	    echo "Swap file line is already in /etc/fstab"
	fi
    echo "Swap file expanded."	
	
	echo "Current Swap File Status:"
	echo "sudo swapon -s"
	sudo swapon -s
	echo ""
	echo "Let's check the memory"
	echo "free -m"
	free -m
	echo ""
	echo "Ok, now let's check the swapieness"
	echo "cat /proc/sys/vm/swappiness"
	cat /proc/sys/vm/swappiness
	echo ""
	echo "Desktops usually have a swapieness of 60 or so, VPS's are usually lower. It should not matter for this application. It is just a curiosity."
	echo "End of Swap File expansion"
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

#Install any utilities you need for the script
echo ""
echo "Installing the JSON parser jq"
sudo apt-get -y install jq
echo ""

## make the directories we are going to use
echo "Make the directories we are going to use"
mkdir -pv $varDynamicBinaries
mkdir -pv $varScriptsDirectory
mkdir -pv $varBackupDirectory

## Create Scripts ##
echo "-------------------------------------------"
echo "Create the scripts we are going to use: "
echo "--"

### Script #1: Stop dynamicd ###
# Filename dynStopDynamicd.sh
cd $varScriptsDirectory
echo "Creating The Stop dynamicd Script: dynStopDynamicd.sh"
echo '#!/bin/sh' > dynStopDynamicd.sh
echo "# This file was generated. $(date +%F_%T) Version: $varVersion" >> dynStopDynamicd.sh
echo "# This script is here to force stop or force kill dynamicd" >> dynStopDynamicd.sh
echo "echo \"\$(date +%F_%T) Stopping the dynamicd if it already running \"" >> dynStopDynamicd.sh
echo "PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynStopDynamicd.sh
echo "if [ \"\" !=  \"\$PID\" ]; then" >> dynStopDynamicd.sh
echo "    if [ -e ${varDynamicBinaries}dynamic-cli ]; then"  >> dynStopDynamicd.sh
echo "        sudo ${varDynamicBinaries}dynamic-cli stop" >> dynStopDynamicd.sh
echo "        echo \"\$(date +%F_%T) Stop sent, waiting 30 seconds\""  >> dynStopDynamicd.sh
echo "        sleep 30" >> dynStopDynamicd.sh
echo "    fi"  >> dynStopDynamicd.sh
echo "# At this point we should be stopped. Let's recheck and kill if we need to. "  >> dynStopDynamicd.sh
echo "    PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynStopDynamicd.sh
echo "    if [ \"\" !=  \"\$PID\" ]; then" >> dynStopDynamicd.sh
echo "        echo \"\$(date +%F_%T) Rouge dynamicd process found. Killing PID: \$PID\""  >> dynStopDynamicd.sh
echo "        sudo kill -9 \$PID" >> dynStopDynamicd.sh
echo "        sleep 5" >> dynStopDynamicd.sh
echo "        echo \"\$(date +%F_%T) Dynamicd has been Killed! PID: \$PID\""  >> dynStopDynamicd.sh
echo "    else"  >> dynStopDynamicd.sh
echo "        echo \"\$(date +%F_%T) Dynamicd has been stopped.\""  >> dynStopDynamicd.sh
echo "    fi" >> dynStopDynamicd.sh
echo "else"  >> dynStopDynamicd.sh
echo "    echo \"\$(date +%F_%T) Dynamic is not running. No need for shutdown commands.\""  >> dynStopDynamicd.sh
echo "fi" >> dynStopDynamicd.sh
echo "# End of generated Script" >> dynStopDynamicd.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynStopDynamicd.sh
echo "Created dynStopDynamicd.sh"
dynStop="${varScriptsDirectory}dynStopDynamicd.sh"
echo "--"

### Script #2: MINING START SCRIPT ###
# Filename dynMineStart.sh
cd $varScriptsDirectory
echo "Creating Mining Start script: dynMineStart.sh"
echo '#!/bin/sh' > dynMineStart.sh
echo "" >> dynMineStart.sh
echo "# This file, dynMineStart.sh, was generated. $(date +%F_%T) Version: $varVersion" >> dynMineStart.sh
echo "echo \"\$(date +%F_%T) Starting Dynamic miner: \$(date)\"" >> dynMineStart.sh
echo "sudo ${varDynamicBinaries}dynamicd --daemon" >> dynMineStart.sh
echo "echo \"\$(date +%F_%T) Waiting 15 seconds \"" >> dynMineStart.sh
echo "sleep 15" >> dynMineStart.sh
echo "# End of generated Script" >> dynMineStart.sh
#./dynamic-cli settxfee 0.0

echo "Changing the file attributes so we can run the script"
chmod +x dynMineStart.sh
echo "Created dynMineStart.sh."
dynStart="${varScriptsDirectory}dynMineStart.sh"
echo "--"

### script #3: GENERATE SCRAPE SCRIPT ###
# Filename: dynScrape.sh
cd $varScriptsDirectory
echo "Creating Scrape script: dynScrape.sh"
echo '#!/bin/sh' > dynScrape.sh
echo "" >> dynScrape.sh
echo "# This file, dynScrape.sh, was generated. $(date +%F_%T) Version: $varVersion" >> dynScrape.sh
echo "" >> dynScrape.sh
echo "myBalance=\$(sudo ${varDynamicBinaries}dynamic-cli getbalance)" >> dynScrape.sh
echo "if [ \"\$myBalance\" = \"\" ] ; then" >> dynScrape.sh
echo "    echo \"\$(date +%F_%T) No Response, is the daemon running, does it exist yet?\"" >> dynScrape.sh
echo "else" >> dynScrape.sh
echo "    if [ \$myBalance != \"0.00000000\" ];then" >> dynScrape.sh
echo "        echo \"\$(date +%F_%T) Scraping a balance of \$myBalance to $myScrapeAddress \"" >> dynScrape.sh
echo "        sudo ${varDynamicBinaries}dynamic-cli sendtoaddress \"$myScrapeAddress\" \$(sudo ${varDynamicBinaries}dynamic-cli getbalance) \"\" \"\" true " >> dynScrape.sh
echo "    fi" >> dynScrape.sh
echo "fi" >> dynScrape.sh
echo "# End of generated Script" >> dynScrape.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynScrape.sh
echo "Created dynScrape.sh."
dynScrape="${varScriptsDirectory}dynScrape.sh"
echo "--"

### script #4: AUTO UPDATER SCRIPT ###
# Filename: dynAutoUpdater.sh
cd $varScriptsDirectory
echo "Creating Scrape script: dynAutoUpdater.sh"
echo '#!/bin/sh' > dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "# This file, dynAutoUpdater,sh, was generated. $(date +%F_%T) Version: $varVersion" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "cd $varGITDynamicPath" >> dynAutoUpdater.sh
echo "if [ \"\`git log --pretty=%H ...refs/heads/master^ | head -n 1\`\" = \"\`git ls-remote $varRemoteRepository -h refs/heads/master |cut -f1\`\" ] ; then " >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : We are up to date.\"" >> dynAutoUpdater.sh
echo "else" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Changes to the repository, Preparing to update.\"" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 1. Download the new source code from the repository if it has been updated" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Remove old repository, we need to do a clean clone for the next version comparison to work. Do not git pull.\"" >> dynAutoUpdater.sh
echo " rm -fdr $varGITDynamicPath" >> dynAutoUpdater.sh
echo " mkdir -p $varGITDynamicPath" >> dynAutoUpdater.sh
echo " cd $varUserDirectory" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Downloading the source code\"" >> dynAutoUpdater.sh
echo " sudo git clone $varRemoteRepository" >> dynAutoUpdater.sh
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
echo " # 3. Scrape if there are any funds before we stop" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Scrape if there are any funds before we stop.\"" >> dynAutoUpdater.sh
echo " sudo ${dynScrape}" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " echo \"Fix for wallets below 1.4.0\"" >> dynAutoUpdater.sh 
echo " sudo ${dynPre_1_4_0_Fix}" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 4. Stop the running daemon" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Stop the running daemon.\"" >> dynAutoUpdater.sh
echo " sudo ${dynStop}" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 5. Replace the executable files" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Replace the executable files.\"" >> dynAutoUpdater.sh
echo " mkdir -pv $varDynamicBinaries" >> dynAutoUpdater.sh
echo " sudo cp -v ${varGITDynamicPath}src/dynamicd $varDynamicBinaries" >> dynAutoUpdater.sh
echo " sudo cp -v ${varGITDynamicPath}src/dynamic-cli $varDynamicBinaries" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " # 6. Start the daemon" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Start the daemon. Mining will automatically start once synced.\"" >> dynAutoUpdater.sh
echo " sudo ${varDynamicBinaries}dynamicd --daemon" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo " echo "waiting 10 seconds"" >> dynAutoUpdater.sh
echo " sleep 10" >> dynAutoUpdater.sh
echo " echo \"GitCheck \$(date +%F_%T) : Now running the latest GIT version.\"" >> dynAutoUpdater.sh
echo "" >> dynAutoUpdater.sh
echo "fi" >> dynAutoUpdater.sh
echo "# End of generated Script" >> dynAutoUpdater.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynAutoUpdater.sh
echo "Created dynAutoUpdater.sh."
dynAutoUpdater="${varScriptsDirectory}dynAutoUpdater.sh"
echo "--"


### Script #5: Fix wallet issues in version 1.4.0 and below ###
# Filename dynPre_1_4_0_Fix.sh
# This file will be deprecated a version or two past where the network no longer connects to versions below 1.4.0
cd $varScriptsDirectory
echo "Creating The Stop dynamicd Script: dynPre_1_4_0_Fix.sh"
echo '#!/bin/sh' > dynPre_1_4_0_Fix.sh
echo "# This file, dynPre_1_4_0_Fix.sh, was generated.  Version: $varVersion" >> dynPre_1_4_0_Fix.sh
echo "# This file will be deprecated a version or two past where the network no longer connects to versions below 1.4.0" >> dynPre_1_4_0_Fix.sh
echo "
echo \"---------------------------------
\$(date +%F_%T)\ dynPre_1_4_0_Fix Started
Take care of the wallet upgrade issue from versions earlier that 1.4.0         
The developers require us to manually export private keys and then import them 
into a new wallet. This is an issue if you keep coins in the wallet. 
This script was built to scape all coins in this instances wallet, and transfer
them to a controller wallet, exchange, or other address. Basically, there 
should be no coins in this wallet. This allows us to simply transfer the coins 
out then delete the wallet.dat file.

We are better than that though. In case something went wrong we should create a
backup of the wallet.dat file, then delete the file.

Step 1: Scrape the coins if they exist\"
sudo $dynScrape

echo \"
Setp 2: Create a backup of the wallet.dat file\"
mkdir -pv ${varBackupDirectory}
sudo cp -v ${varDynamicConfigDirectory}wallet.dat ${varBackupDirectory}wallet_backup_\$(date +%Y%m%d_%H%M%S).dat

echo \"
Step 3: If we are not running, or we are running a version less than version then we get rid of the wallet.dat file.\"
myVersion=\"\$(sudo ./dynamic-cli getinfo | jq -r '.version')\"
echo \"Current Version returned: \\\"\$myVersion\\\"\"

if [ \"\$myVersion\" = \"\" ] ; then
    echo \"Because dynamic is not running or not installed we do not know the version. We are going to backup the file anyways\"
    sudo ${dynStop}
    mv -v ${varDynamicConfigDirectory}wallet.dat ${varDynamicConfigDirectory}wallet_backup_Version_unknown_\$(date +%Y%m%d_%H%M%S).dat
else
    if [ \"\$myVersion\" -ge 1040000 ];then
        echo \"Our version is greater than or equal to version 1.4.0, backing up the wallet.dat file, but keeping the exising wallet in place\"
		cp -v ${varDynamicConfigDirectory}wallet.dat ${varDynamicConfigDirectory}wallet_backup_Version_\${\$myVersion}_\$(date +%Y%m%d_%H%M%S).dat
    else
        echo \"Our version is less than 1.4.0, stop dynamic and move the wallet file\"
		sudo ${dynStop}
		mv -v ${varDynamicConfigDirectory}wallet.dat ${varDynamicConfigDirectory}wallet_backup_Version_\${\$myVersion}_\$(date +%Y%m%d_%H%M%S).dat
    fi
fi
sleep 1
echo \"\$(date +%F_%T) dynPre_1_4_0_Fix Finished\"
echo \"---------------------------------\"
#end of generated file" >> dynPre_1_4_0_Fix.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynPre_1_4_0_Fix.sh
echo "Created dynPre_1_4_0_Fix.sh"
dynPre_1_4_0_Fix="${varScriptsDirectory}dynPre_1_4_0_Fix.sh"
echo "--"




### Script #5: Watchdog, Checks to see if the process is running and restarts it if it is not. ###
# Filename dynWatchdog.sh
cd $varScriptsDirectory
echo "Creating The Stop dynamicd Script: dynWatchdog.sh"
echo '#!/bin/sh' > dynWatchdog.sh
echo "# This file, dynWatchdog.sh, was generated. $(date +%F_%T) Version: $varVersion" >> dynWatchdog.sh
echo "# This script checks to see if dynamicd is running. If it is not, then it will be restarted. " >> dynWatchdog.sh
echo "PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynWatchdog.sh
echo "if [ \"\" =  \"\$PID\" ]; then" >> dynWatchdog.sh
echo "    if [ -e ${varDynamicBinaries}dynamic-cli ]; then"  >> dynWatchdog.sh
echo "        echo \"\$(date +%F_%T) STOPPED: Wait 3 minutes. We could be in an auto-update or other momentary restart.\""  >> dynWatchdog.sh
echo "        sleep 180" >> dynWatchdog.sh
echo "        PID=\`ps -eaf | grep dynamicd | grep -v grep | awk '{print \$2}'\`" >> dynWatchdog.sh
echo "        if [ \"\" =  \"\$PID\" ]; then" >> dynWatchdog.sh
echo "            echo \"\$(date +%F_%T) Starting: Attempting to start the dynamic daemon \""  >> dynWatchdog.sh
echo "            sudo ${dynStart}" >> dynWatchdog.sh
echo "            echo \"\$(date +%F_%T) Starting: Attempt complete. We will see if it worked the next watchdog round. \""  >> dynWatchdog.sh
echo "        else"  >> dynWatchdog.sh
echo "            echo \"\$(date +%F_%T) Running: Must have been some reason it was down. \""  >> dynWatchdog.sh
echo "        fi"  >> dynWatchdog.sh
echo "    else"  >> dynWatchdog.sh
echo "        echo \"\$(date +%F_%T) Error the file ${varDynamicBinaries}dynamic-cli does not exist! \""  >> dynWatchdog.sh
echo "    fi"  >> dynWatchdog.sh
echo "else"  >> dynWatchdog.sh
echo "    myBlockCount=\$(sudo ${varDynamicBinaries}dynamic-cli getblockcount)"  >> dynWatchdog.sh
echo "    myHashesPerSec=\$(sudo ${varDynamicBinaries}dynamic-cli gethashespersec)"  >> dynWatchdog.sh
echo "    echo \"\$(date +%F_%T) Running: Block Count: \$myBlockCount Hash Rate: \$myHashesPerSec \""  >> dynWatchdog.sh
echo "fi" >> dynWatchdog.sh
echo "# End of generated Script" >> dynWatchdog.sh
echo "Changing the file attributes so we can run the script"
chmod +x dynWatchdog.sh
echo "Created dynWatchdog.sh"
dynWatchdog="${varScriptsDirectory}dynWatchdog.sh"
echo "--"


echo "Done creating scripts"
echo "-------------------------------------------"




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
 
 mkdir -pv $varDynamicConfigDirectory
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
#Permanent lockdown and security of the node/miner. Not implementing before we work out the bugs. (don't want to lock us out from debugging it)
####### RESERVED For Security Lockdown Function #############

echo "Lets Scrape, if this is an upgrade, you may have mined coins."
sudo ${dynScrape}
echo "--"
echo "Fix for wallets below 1.4.0"
sudo ${dynPre_1_4_0_Fix}
echo "--"

## Quick Start Get Botstrap Data, recommended by the development team.
if [ "$varQuickBootstrap" = true ]; then
    echo "Starting Bootstrap and Blockchain download."
    echo "Step 1: If the dynamicd process is running, Stop it"
    sudo ${dynStop}

    echo "Step 2: Backup wallet.dat files"
    #We are not backing up the full data directory contrary to the instructions. The reason is that this is most likely an automated situation and a backup will just waste space
    myBackupDirectory="${varBackupDirectory}Backup$(date +%Y%m%d_%H%M%S)/"
    mkdir -pv ${myBackupDirectory}backups/
    sudo cp -r ${varDynamicConfigDirectory}backups/* ${myBackupDirectory}backups/
    sudo cp -v ${varDynamicConfigDirectory}wallet.dat ${myBackupDirectory}
    sudo cp -v ${varDynamicConfigDirectory}dynamic.conf ${myBackupDirectory}
	sudo cp -v ${varDynamicConfigDirectory}dncache.dat ${myBackupDirectory}
    echo "Files backed up to ${myBackupDirectory}"

    echo "Step 3: Delete all data apart from your wallet.dat, conf files and backup folder."
    rm -fdr $varDynamicConfigDirectory
    #we make sure the directory is there for the script.
    mkdir -pv $varDynamicConfigDirectory

    echo "Step 4: Download the bootstrap.dat compressed file"

    mkdir -pv ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."

    rm -fdr $varQuickStartCompressedBootstrapFileName
    mkdir -pv $varDynamicConfigDirectory
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

    echo "Step 5: Start Dynamic and import from bootstrap.dat. Daemon users need to use the \"--loadblock=\" argument when starting Dynamic"
    echo "We will complete this step later on in the setup file, either on download of the binaries, or on completion of the compellation if you don't download the binaries"
    sleep 1
    echo "Bootstrap Prep completed!"
    echo ""
fi


## blockchain download (get blockchain from the web, not completely safe or reliable, but fast!)

## Quick Start (get blockchain from the web, not completely safe or reliable, but fast!)
## If you are bootstraping, you can still download the blockchain. While the developers recommend you only bootstrap, this will save time while syncing.
## 
if [ "$varQuickBlockchainDownload" = true ]; then
    echo "Blockchain Download"
    
	echo "Step 1: If the dynamicd process is running, Stop it"
    sudo ${dynStop}

    echo "Step 2: Backup wallet.dat files"
    #We are not backing up the full data directory contrary to the instructions. The reason is that this is most likely an automated situation and a backup will just waste space
	sleep 2
    myBackupDirectory="${varBackupDirectory}Backup$(date +%Y%m%d_%H%M%S)/"
    mkdir -pv ${myBackupDirectory}backups/
    sudo cp -r ${varDynamicConfigDirectory}backups/* ${myBackupDirectory}backups/
    sudo cp -v ${varDynamicConfigDirectory}wallet.dat ${myBackupDirectory}
    sudo cp -v ${varDynamicConfigDirectory}dynamic.conf ${myBackupDirectory}
	sudo cp -v ${varDynamicConfigDirectory}dncache.dat ${myBackupDirectory}
    echo "Files backed up to ${myBackupDirectory}"

    echo "Step 3: Delete all data apart from your wallet.dat, conf files and backup folder."
    rm -fdr $varDynamicConfigDirectory
    #we make sure the directory is there for the script.
    mkdir -pv $varDynamicConfigDirectory

    echo "Step 4: Download the blockchain compressed file"

    mkdir -pv ${varUserDirectory}QuickStart
    cd ${varUserDirectory}QuickStart

    echo "Downloading blockchain bootstrap and extracting to data folder..."
    sudo apt-get -y install unzip
    rm -fdr $varQuickStartCompressedBlockChainFileName
    wget $varQuickStartCompressedBlockChainLocation
	
	if [ $? -eq 0 ]; then
	    echo "Download succeeded, extract ..."
        mkdir -pv $varDynamicConfigDirectory
        if [ "$varQuickStartCompressedBlockChainFileIsZip" = true ]; then
            sudo apt-get -y install unzip
            unzip -o $varQuickStartCompressedBlockChainFileName -d $varDynamicConfigDirectory
            echo "Extracted Zip file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varDynamicConfigDirectory )"
        else
            tar -xvf $varQuickStartCompressedBlockChainFileName -C $varDynamicConfigDirectory
            echo "Extracted TAR file ( $varQuickStartCompressedBlockChainFileName ) to the config directory ( $varDynamicConfigDirectory )"
        fi
	else
	    echo "Blockchain Download Failed"
	    varQuickBlockchainDownload=false
	fi

    echo "Finished blockchain download and extraction"
    echo ""
fi

## Creating the config file. This prevents the boot up, have to shut down thing in dynamicd. We do this here just in case the quickstart stuff deletes the config file.
echo ""
echo "Ok, now we are going to modify the dynamic.conf file so that when you boot up dynamicd, you will be mining. No need to invoke dynamic-cli setgenerate true"
funcCreateDynamicConfFile
echo "Now that we have crated the dynamic.conf file, there is no need to do the boot up shut down thing with dyanmicd"
echo ""


## Quick Start (get binaries from the web, not completely safe or reliable, but fast!)
if [ "$varQuickStart" = true ]; then
echo "Beginning QuickStart Executable (binaries) download and start"

echo "If the dynamicd process is running, this will kill it."
sudo ${dynStop}

mkdir -pv ${varUserDirectory}QuickStart
cd ${varUserDirectory}QuickStart
echo "Downloading and extracting Dynamic binaries"
rm -fdr $varQuickStartCompressedFileName
wget $varQuickStartCompressedFileLocation
tar -xzf $varQuickStartCompressedFileName

echo "Copy QuickStart binaries"
mkdir -pv $varDynamicBinaries
sudo cp -v $varQuickStartCompressedFilePathForDaemon $varDynamicBinaries
sudo cp -v $varQuickStartCompressedFilePathForCLI $varDynamicBinaries


echo "Launching daemon for the first time."
if [ "$varQuickBootstrap" = true ]; then
  echo "sudo ${varDynamicBinaries}dynamicd --daemon --loadblock=${varDynamicConfigDirectory}bootstrap.dat"
  sudo ${varDynamicBinaries}dynamicd --daemon --loadblock=${varDynamicConfigDirectory}bootstrap.dat 
else
  echo "sudo ${varDynamicBinaries}dynamicd --daemon"
  sudo ${varDynamicBinaries}dynamicd --daemon
fi

echo "The Daemon has started."

if [ $varQuickBlockchainDownload = true ] ; then
	# Downloading the blockchain is significantly faster. you will most likely be mining within 5 min. 
    echo "We have downloaded the blockchain and the binaries, let's give some time for the blockchain to load"
	echo "Out of all of the options, this is the fastest and actually has a chance of completing before compiling starts"
    echo "Sleeping for 15 min"
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
    do
        sleep 60
        echo "$i out of 15 min completed"
    done
	echo "sudo ${varDynamicBinaries}dynamic-cli gethashespersec"
    sudo ${varDynamicBinaries}dynamic-cli gethashespersec
    echo "* note: hash rate may be 0 if the blockchain has not fully synced yet."
else
    echo "Waiting 60 seconds"
    sleep 60
fi


echo "Wait period over We are currently on Block:"
echo "sudo ${varDynamicBinaries}dynamic-cli getblockcount"
sudo ${varDynamicBinaries}dynamic-cli getblockcount
echo "A full sync can take many hours. Mining will automatically start once synced."
sleep 1

echo ""
echo "In case Compiling later on fails, we want to put all of our cron jobs in"
echo ""

## CREATE CRON JOBS ###
echo "Creating Boot Start and Scrape Cron jobs..."

startLine="@reboot sh $dynStart >> ${varScriptsDirectory}dynMineStart.log 2>&1"
scrapeLine="*/$varMiningScrapeTime * * * * $dynScrape >> ${varScriptsDirectory}dynScrape.log 2>&1"

(crontab -u root -l 2>/dev/null | grep -v -F "$dynStart"; echo "$startLine") | crontab -u root -
echo " cron job $dynStart is setup: $startLine"
(crontab -u root -l 2>/dev/null | grep -v -F "$dynScrape"; echo "$scrapeLine") | crontab -u root -
echo " cron job $dynScrape is setup: $scrapeLine"

if [ "$varWatchdogEnabled" = true ]; then
    watchdogLine="*/$varWatchdogTime * * * * $dynWatchdog >> ${varScriptsDirectory}dynWatchdog.log 2>&1"
    (crontab -u root -l 2>/dev/null | grep -v -F "$dynWatchdog"; echo "$watchdogLine") | crontab -u root -
	echo " cron job $dynWatchdog is setup: $watchdogLine"
fi

echo "Boot Start and Scrape cron jobs created"


echo "QuickStart complete"
fi
#End of QuickStart
echo ""
echo ""

# Compile the code
if [ "$varCompile" = true ]; then

    echo "######### Start Compile #########"
    echo ""
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
    echo ""
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
    sudo ${dynStop}

    echo "Copy compiled binaries, if you used QuickStart your binaries are being replaced by the compiled ones"
    mkdir -pv $varDynamicBinaries
    sudo cp -v ${varGITDynamicPath}src/dynamicd $varDynamicBinaries
    sudo cp -v ${varGITDynamicPath}src/dynamic-cli $varDynamicBinaries
    
    if [ "$varQuickBootstrap" = true ]; then
    
        if [ "$varQuickStart" = true ]; then
            echo "skipping the pre-launch because we already did it with the quickstart"
	        echo "sudo ${varDynamicBinaries}dynamicd --daemon"
	        sudo ${varDynamicBinaries}dynamicd --daemon
        else
            echo "Doing the bootstrap from step 4 here because we want to boot strap"
	        echo "sudo ${varDynamicBinaries}dynamicd --daemon --loadblock=${varDynamicConfigDirectory}bootstrap.dat"
            sudo ${varDynamicBinaries}dynamicd --daemon --loadblock=${varDynamicConfigDirectory}bootstrap.dat
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

    startLine="@reboot sh $dynStart >> ${varScriptsDirectory}dynMineStart.log 2>&1"
    scrapeLine="*/$varMiningScrapeTime * * * * $dynScrape >> ${varScriptsDirectory}dynScrape.log 2>&1"

    (crontab -u root -l 2>/dev/null | grep -v -F "$dynStart"; echo "$startLine") | crontab -u root -
    echo " cron job $dynStart is setup: $startLine"
    (crontab -u root -l 2>/dev/null | grep -v -F "$dynScrape"; echo "$scrapeLine") | crontab -u root -
    echo " cron job $dynScrape is setup: $scrapeLine"
    
    if [ "$varWatchdogEnabled" = true ]; then
        watchdogLine="*/$varWatchdogTime * * * * $dynWatchdog >> ${varScriptsDirectory}dynWatchdog.log 2>&1"
        (crontab -u root -l 2>/dev/null | grep -v -F "$dynWatchdog"; echo "$watchdogLine") | crontab -u root -
    	echo " cron job $dynWatchdog is setup: $watchdogLine"
    fi

    if [ "$varAutoUpdate" = true ]; then

        #we don't want eveyone updating at the same time, that would be bad for the network, so check for updates at a random time.
        AutoUpdaterLine="$(shuf -i 0-59 -n 1) $(shuf -i 0-23 -n 1) * * * $dynAutoUpdater >> ${varScriptsDirectory}dynAutoUpdater.log 2>&1"
        #this will check once a day, just at a random time of day from other runs of this script. 

        (crontab -u root -l 2>/dev/null | grep -v -F "$dynAutoUpdater"; echo "$AutoUpdaterLine") | crontab -u root -
        echo " cron job $dynAutoUpdater is setup: $AutoUpdaterLine"
        echo " Auto Update cron job has been set:"
        echo " Auto Update will run once a day and automatically compile and execute new code if there have been commits to the remote repository."
        echo " Remote Repository: $varRemoteRepository"
    else
        echo " Auto Update is set to false. We will not update if new code is updated in the repository: $varRemoteRepository"
    fi


    echo "Created cron jobs."
    echo "-------------------------------------------"
fi
	
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

Alternatively, you can put the path (directory) before the command

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
end of startup script
"
