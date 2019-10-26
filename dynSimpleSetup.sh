#!/bin/sh

# Summary:
# This script makes setting up Dynamic (DYN) miners and remote dynodes easy!
# It will download the latest startup script which can:
#  * Download and run the executables
#  * Download the Bootstrap
#  * Download the Blockchain
#  * Auto Scrapes
#  * Auto Updates
#  * Watchdog to keep the mining going just in case of a crash
#  * Startup on reboot
#  * Can create miners
#  * Can create remote Dynodes
#  * Auto optimizes for your CPU: SSSE3, AVX2, AVX512F, and more
#  and more... See https://github.com/LordDarkHelmet/DynamicScripts for the latest
#
# You can run this as one command on the command line
# wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sh dynSimpleSetup.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR
#
echo "===========================================================================" | tee -a dynSimpleSetup.log
echo "Version 2.4.1 of dynSimpleSetup.sh" | tee -a dynSimpleSetup.log
echo " Released October 26, 2019 Released by LordDarkHelmet" | tee -a dynSimpleSetup.log
echo "Original Version found at: https://github.com/LordDarkHelmet/DynamicScripts" | tee -a dynSimpleSetup.log
echo "Local Filename: $0" | tee -a dynSimpleSetup.log
echo "Local Time: $(date +%F_%T)" | tee -a dynSimpleSetup.log
echo "System:" | tee -a dynSimpleSetup.log
uname -a | tee -a dynSimpleSetup.log
echo "User $(id -u -n)  UserID: $(id -u)" | tee -a dynSimpleSetup.log
echo "If you found this script useful please contribute. Feedback is appreciated" | tee -a dynSimpleSetup.log
echo "===========================================================================" | tee -a dynSimpleSetup.log
varIsScrapeAddressSet=false
varShowHelp=false
#By Default we are not mining. Do not warn about scrape addresses if we are not mining. 
varAmIMining=false
while getopts :s:h option
do
	case "${option}" in
		h)
			varShowHelp=true
			#We are setting this to true because we are going to show help. No need to worry about scraping
			varIsScrapeAddressSet=true
			echo "We are going to show the most recent help info." | tee -a dynSimpleSetup.log
			echo "In order to do this we will still need to download the latest version from GIT." | tee -a dynSimpleSetup.log
			;;
		s)
			myScrapeAddress=${OPTARG}
			echo "-s has set myScrapeAddress=${myScrapeAddress}" | tee -a dynSimpleSetup.log
			varIsScrapeAddressSet=true
			;;
		m)
            if [ "$( echo "${OPTARG}" | tr '[A-Z]' '[a-z]' )" = false ]; then
                varAmIMining=false
                echo "-m Mining has been set to false. We will disable mining."
            else
                varAmIMining=true
                echo "-m Mining has been set to true. We will be mining."
            fi	
			;;
	esac
done

if [ "${varIsScrapeAddressSet}" = false ]; then
	if [ "${varAmIMining}" = true ]; then
		echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a dynSimpleSetup.log
		echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a dynSimpleSetup.log
		echo "SCRAPE ADDRESS HAS NOT BEEN SET!!! You will be donating your HASH power." | tee -a dynSimpleSetup.log
		echo "If you did not intend to do this then please use the -s attribute and set your scrape address!" | tee -a dynSimpleSetup.log
		echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a dynSimpleSetup.log
		echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a dynSimpleSetup.log
	fi
fi

echo "" | tee -a dynSimpleSetup.log
echo "" | tee -a dynSimpleSetup.log
echo "Step 1: Update the system to ensue it knows where to find GIT" | tee -a dynSimpleSetup.log
sudo apt-get -y update | tee -a dynSimpleSetup.log
echo "Step 2: Download the latest dynStartupScript.sh from GitHub, https://github.com/LordDarkHelmet/DynamicScripts" | tee -a dynSimpleSetup.log
echo "- To download from GitHub we need to install GIT" | tee -a dynSimpleSetup.log
sudo apt-get -y install git | tee -a dynSimpleSetup.log
echo "- we also use the \"at\" command we should install that too. " | tee -a dynSimpleSetup.log
sudo apt-get -y install at | tee -a dynSimpleSetup.log
echo "- Clone the repository" | tee -a dynSimpleSetup.log
sudo git clone https://github.com/LordDarkHelmet/DynamicScripts | tee -a dynSimpleSetup.log
echo "- Navigate to the script" | tee -a dynSimpleSetup.log
cd DynamicScripts
echo "- Just in case we previously ran this script, pull the latest from GitHub" | tee -a ../dynSimpleSetup.log
sudo git fetch --all
sudo git reset --hard origin/master
sudo git pull https://github.com/LordDarkHelmet/DynamicScripts | tee -a ../dynSimpleSetup.log
echo "" | tee -a dynSimpleSetup.log
echo "Step 3: Set permissions so that dynStartupScript.sh can run" | tee -a ../dynSimpleSetup.log
echo "- Change the permissions" | tee -a ../dynSimpleSetup.log
chmod +x dynStartupScript.sh | tee -a ../dynSimpleSetup.log
echo "" | tee -a ../dynSimpleSetup.log
echo "Step 4: Run the script." | tee -a ../dynSimpleSetup.log

if [ "$varShowHelp" = true ]; then
	echo "./dynStartupScript.sh -h" | tee -a ../dynSimpleSetup.log
	./dynStartupScript.sh -h  | tee -a ../dynSimpleSetup.log
else
	varLogFilename="dynStartupScript$(date +%Y%m%d_%H%M%S).log"
	#Due to the fact that some VPN servers have not enabled RemainAfterExit=yes", which if neglected, causes systemd to terminate all spawned processes from the imageboot unit, we need to schedule the script to run.
	#Because of that flaw, we are going to use the at command to schedule the process
	echo "" | tee -a ../dynSimpleSetup.log
	echo "$(date +%F_%T) Scheduling the script to run 2 min from now. We do this instead of nohup or setsid because some VPSs terminate " | tee -a ../dynSimpleSetup.log
	echo "We will execute the following command in 2 min:  ./dynStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &" | tee -a ../dynSimpleSetup.log
	#at command used on this line to launch. 
	echo "./dynStartupScript.sh $@ 1> $varLogFilename 2>&1 < /dev/null &" | at now + 2 minutes  | tee -a ../dynSimpleSetup.log
	echo "" | tee -a ../dynSimpleSetup.log
	echo "If you want to follow its progress (once it starts in 2 min) then use the following command:" | tee -a ../dynSimpleSetup.log
	echo "" | tee -a ../dynSimpleSetup.log
	echo "tail -f ${PWD}/${varLogFilename}" | tee -a ../dynSimpleSetup.log
	echo "" | tee -a ../dynSimpleSetup.log
fi
