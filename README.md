# DynamicScripts
<b>Scripts for the Dynamic (DYN) Cryptocurrency</b>

Setup a Dynode with one line! You can generate a pairing key from any wallet using the <code>dynode genkey</code> command. We recommend the latest Ubuntu LTS 18.04 version as the OS, but any version is compatible. 

<code>wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sudo sh dynSimpleSetup.sh -d ReplaceMeWithOutputFrom_dynode_genkey</code>

You can also setup a dynamic miner with one line! Example: (<i>be sure to replace the address with your scrape address</i>)

<code>wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sudo sh dynSimpleSetup.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -m true</code>

The script can: 
 * Create remote dynodes
 * Create miners
 * Auto Scrapes
 * Auto Updates
 * Watchdog to keep the mining going just in case of a crash
 * Startup on reboot
 * Download and run the executables
 * Download the Bootstrap
 * Download the Blockchain
 * Auto optimizes for your CPU: SSSE3, AVX2, AVX512F, and more
 * If you are using [Vultr](http://www.vultr.com/?ref=6923885) as your VPS provider, the script can update the server name to give you up to date status info
 * and more...
 
 Use the -h command to see the full list of capabilities and options, Examples are provided.    
 
 <code>wget -N https://github.com/LordDarkHelmet/DynamicScripts/releases/download/v1.0.0/dynSimpleSetup.sh && sudo sh dynSimpleSetup.sh -h</code>
 

This is a collection of scripts that will assist users in setting up and managing instances of the dynamic wallet.

<b>dynSimpleSetup.sh</b>
This script is used in conjunction with the dynStartupScript.sh script. It is a non, or rarely changing script that will pull the latest dynStartupScript.sh script and run it. This allows us to have a static location for a release script so we can use one-line startup commands while always running the latest script. 

<b>dynStartupScript.sh:</b>
This script is a one stop shop. Run it on your VPS and it will do everything hands off. It will mine for you, it will scrape for you, it will auto update when new versions come out, it can even setup a dynode for you. Simple and easy. If you set it as a startup script, you will never need to log into your VPS.


Dynamic (DYN) is a cryptocurrency. You can find out more at:
https://duality.solutions/dynamic/

<b>Options:</b>
Use these attributes to customize your deployment:

<code>-s Scrape address requires an attribute Ex.  -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR</code>

<code>-d Dynode Pairing key. if you populate this it will setup a Dynode.  ex -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey
     You can also pre-enable a dynode by using the following: -d unknown</code>
     
 <code>-y Dynode Label, a human readable label for your Dynode. Useful with the -v option.</code>
 
 <code>-a Auto Updates. Turns auto updates (on by default) on or off, ex -a true</code>
 
 <code>-r Auto Repair. Turn auto repair on (default) or off, ex -r true</code>
 
 <code>-l System Lockdown. Secure the instance. True to lock down your system. ex -l true</code>
 
 <code>-w Watchdog. The watchdog restarts processes if they fail. true for on, false for off. </code>
 
 <code>-c Compile. Compile the code, default is true. If you set it to false it will also turn off AutoUpdate</code>
 
 <code>-v Vultr API. see http://www.vultr.com/?ref=6923885 If you are using Vultr as an API service, this will change the label to update the last watchdog status</code>
 
 <code>-b bootstrap or blockchain. Download an external bootstrap, blockchain or none, ex"-b bootstrap"</code>
 
 <code>-m Mining. enables or disables mining. true for on, false for off. Off by default. ex"-m true" to enable mining</code>
 
 <code>-t Various test attributes (in development)</code>
 
 <code>-h Display Help then exit.</code>


<b>Examples:</b>

Example 1: Just set up a simple miner (use the -m attribute to turn on mining)

<code>sudo sh ./dynStartupScript.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -m true</code>

Example 2: Setup a remote Dynode that also mines. Not recommended for VPS's as most provides will ban you. 

<code>sudo sh ./dynStartupScript.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey -m true</code>

Example 3: Setup a remote Dynode that does not mine. Great for VPS's that will ban high CPU usage. (mining is turned off by default)

<code>sudo sh ./dynStartupScript.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey</code>

Example 4: Run a miner, but don't compile (auto update will be turned off by default), useful for low RAM VPS's that don't allow for SWAP files

<code>sudo sh ./dynStartupScript.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -c false -m true</code>

Example 5: Turn off auto update on a Dynode, you will be required to manually update if a new version comes along

<code>sudo sh ./dynStartupScript.sh -s D9T2NVLGZEFSw3yc6ye4BenfK7n356wudR -d ReplaceMeWithOutputFrom_dynamic-cli_dynode_genkey -a false</code>

The "-d unknown" attribute allows you to pre-setup a Dynode. The dynode will create the dynode pairing key that your control wallet can use. You can see it at the end of the log file or in the dynamic.conf file.

The "-v API_KEY" attribute is very useful if [Vultr](http://www.vultr.com/?ref=6923885) is your service provider. It will update your server name with the current status. You can see the status of all of your servers right from the Vultr website. The server name is the status. The tag is the Dynode pairing key.

Using the -v and -d unknown allows you to create a Dynode without ever logging into the VPS. No coding skills or tools needed. 
