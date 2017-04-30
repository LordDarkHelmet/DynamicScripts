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
#  * Can create remote dynodes
#  and more... See https://github.com/LordDarkHelmet/DynamicScripts for the latest. 
#

echo "===========================================================================" | tee -a DynamicSimpleSetup.log
echo "Version 1.0.0 of DynamicSimpleSetup.sh" | tee -a DynamicSimpleSetup.log
echo " Released April 29, 2017 Released by LordDarkHelmet" | tee -a DynamicSimpleSetup.log
echo "Original Version found at: https://github.com/LordDarkHelmet/DynamicScripts" | tee -a DynamicSimpleSetup.log
echo "Local Filename: $0" | tee -a DynamicSimpleSetup.log
echo "Local Time: $(date +%F_%T)" | tee -a DynamicSimpleSetup.log
echo "System:" | tee -a DynamicSimpleSetup.log
uname -a | tee -a DynamicSimpleSetup.log
echo "If you found this script useful please contribute. Feedback is appreciated" | tee -a DynamicSimpleSetup.log
echo "===========================================================================" | tee -a DynamicSimpleSetup.log
varIsScrapeAddressSet=false
varShowHelp=false
while getopts :s:h option
do
	case "${option}"
	in 
		h)
			varShowHelp=true
			#We are setting this to true because we are going to show help. No need to worry about scraping
			varIsScrapeAddressSet=true
			echo "We are going to show the most recent help info." | tee -a DynamicSimpleSetup.log
			echo "In order to do this we will still need to download the latest version from GIT." | tee -a DynamicSimpleSetup.log
			;;
		s) 
			myScrapeAddress=${OPTARG}
			echo "-s has set myScrapeAddress=${myScrapeAddress}" | tee -a DynamicSimpleSetup.log
			varIsScrapeAddressSet=true
			;;
	esac
done

if [ "$varIsScrapeAddressSet" = false ]; then
echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a DynamicSimpleSetup.log
echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a DynamicSimpleSetup.log
echo "SCRAPE ADDRESS HAS NOT BEEN SET!!! You will be donating your HASH power." | tee -a DynamicSimpleSetup.log
echo "If you did not intend to do this then please use the -a attribute and set your scrape address!" | tee -a DynamicSimpleSetup.log
echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a DynamicSimpleSetup.log
echo "=!!!!!= WARNING WARNING WARNING WARNING WARNING WARNING =!!!!!=" | tee -a DynamicSimpleSetup.log
fi

echo "" | tee -a DynamicSimpleSetup.log
echo "" | tee -a DynamicSimpleSetup.log
echo "Step 1: Download the latest dynStartupScript.sh from GitHub, https://github.com/LordDarkHelmet/DynamicScripts" | tee -a DynamicSimpleSetup.log
echo "- To download from GitHub we need to install GIT" | tee -a DynamicSimpleSetup.log
sudo apt-get -y install git | tee -a DynamicSimpleSetup.log
echo "- Clone the repository" | tee -a DynamicSimpleSetup.log
sudo git clone https://github.com/LordDarkHelmet/DynamicScripts | tee -a DynamicSimpleSetup.log
echo "- Navigate to the script" | tee -a DynamicSimpleSetup.log
cd DynamicScripts
echo "- Just in case we previously ran this script, pull the latest from GitHub" | tee -a DynamicSimpleSetup.log
sudo git pull https://github.com/LordDarkHelmet/DynamicScripts | tee -a DynamicSimpleSetup.log
echo "" | tee -a DynamicSimpleSetup.log
echo "Step 2: Set permissions so that dynStartupScript.sh can run" | tee -a DynamicSimpleSetup.log
echo "- Change the permissions" | tee -a DynamicSimpleSetup.log
chmod +x dynStartupScript.sh | tee -a DynamicSimpleSetup.log
echo "" | tee -a DynamicSimpleSetup.log
echo "Step 3: Run the script." | tee -a DynamicSimpleSetup.log

if [ "$varShowHelp" = true ]; then
	echo "./dynStartupScript.sh -h" | tee -a DynamicSimpleSetup.log
	./dynStartupScript.sh -h  | tee -a DynamicSimpleSetup.log
else
	varLogFilename="dynStartupScript$(date +%Y%m%d_%H%M%S).log"
	echo "nohup ./dynStartupScript.sh $@ > $varLogFilename 2>&1 &"
	nohup ./dynStartupScript.sh $@ > $varLogFilename 2>&1 &
	PID=`ps -eaf | grep dynStartupScript.sh | grep -v grep | awk '{print \$2}'`
	echo "The script is now running in the background. PID=${PID}" | tee -a DynamicSimpleSetup.log
	echo "" | tee -a DynamicSimpleSetup.log
	echo "If you want to follow its progress use the following command:" | tee -a DynamicSimpleSetup.log
	echo "" | tee -a DynamicSimpleSetup.log
	echo "tail -f ${PWD}/${varLogFilename}" | tee -a DynamicSimpleSetup.log
	echo "" | tee -a DynamicSimpleSetup.log
fi

