# No-Mo-Head

Note: This is a fork of hrishioa's nomohead with some fixes and improvements as it was originally broken.

Here's a bit of background: I frequently use my Pi in headless mode, but I live in a University where the WiFi doesn't let you use static IPs, and you also can't port-forward for servers hosted on your Pi. I've implemented a number of workarounds for this problem, but this is the one that stuck. If you can connect to the internet but have a problem connecting to the Pi, this could help.

## Installation

First clone the repository (if you have git on your Raspi. If not, just download):
```
git clone https://github.com/OscarVanL/nomohead.git
```
Move into the cloned directory
```
cd nomohead
```
Install dependencies (Apparently curl isn't always preinstalled?!?)
```
sudo apt-get install wget curl
```
Next, run the install script:
```
./setup.sh
```

Setup asks for the following parameters:
1. ngrok auth token - Go to https://dashboard.ngrok.com/get-started, create an account and enter the authtoken in part 3 "Connect your account".
2. Dweet Name - The name used to dweet your ngrok tunnel address to. Enter something you think is unique (i.e. not raspi). http://dweet.io/follow/<THIS NAME HERE>
3. Port - the port you want the tunnel to access, for example port 22 for remote SSH access.
4. Delay - The amount of time between pushes to dweet.io, I set this to 1 minute, but it could be less frequent. This delay is also before the *first* dweet after a reboot; having it too slow may cause you to have to wait to find out the tunnel address after a reboot.

Once all values are entered, a cron job is created that runs the nomohead script at boot.

At this point, you should reboot your Pi.

## Dweets

In order to find your raspberry pi's tunnel and IP information, you can go to 
```
http://dweet.io/follow/<RASPID>
```
replace <RASPID> with the Tunnel ID you gave during Setup. 

## Limitations
Only one ngrok tunnel can exist for a free account. In my case, I have two Raspberry Pis and want two tunnels, but if I try to run the script on both Pis only one is successful.
To bypass this limitation, I found that if I start one Pi on the USA ngrok server and the other on the EU server this bypasses this limitation.
This allows me to have two ngrok tunnels on a free account!

#### Happy Hacking!
