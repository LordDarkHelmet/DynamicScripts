# DynamicScripts
<b>Scripts for the Dynamic (DYN) Cryptocurrency</b>

<b> NOTE: Version 1.0.29 is for the 1.5v1 test net only. This is a test run by duality. Mined coins will be swapped by duality 1:1. Dynode rewards will not be creditied in any way. </b>

You can now setup a dynamic miner with one line! Example: (<i>be sure to replace the address with your scrape address</i>)

<code>wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sudo sh dynSimpleSetup.sh -s DPkq3HeNYgHkwDMwfHxeTKu25VL4tK323z</code>

The above line will download the latest startup script which can: 
 * Create miners
 * Create remote dynodes
 * Auto Scrapes
 * Auto Updates
 * Watchdog to keep the mining going just in case of a crash
 * Startup on reboot
 * Download and run the executables
 * Download the Bootstrap
 * Download the Blockchain
 * and more...
 
 You can also setup dynodes with one line. Use the -h command to see the full list of capabilietes and options, Examples are provided.  
 
 <code>wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sudo sh dynSimpleSetup.sh -h</code>
 

This is a collection of scripts that will assist users in setting up and managing instances of the dynamic wallet.

<b>dynSimpleSetup.sh</b>
This script is used in conjunction with the dynStartupScript.sh script. It is a non, or rarely changing script that will pull the latest dynStartupScript.sh script and run it. This allows us to have a static location for a release script so we can use one line startup commands while always running the latest script. 

<b>dynStartupScript.sh:</b>
This script is a one stop shop. Run it on your VPS and it will do everything hands off. It will mine for you, it will scrape for you, it will auto update when new versions come out, it can even setup a dynode for you. Simple and easy. If you set it as a startup script, you will never need to log into your VPS.


Dynamic (DYN) is a cryptocurrency. You can find out more at:
https://dynamic.duality.solutions/
