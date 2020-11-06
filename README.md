# No-Mo-Head

This is a fork of hrishioa's nomohead, it improves on the original project in a few ways:
 * Support for both Unix and Windows
 * Create tunnels to arbitrary ports
 * Automatic executable downloading
 * Bug fixes
 

Here's a bit of background: I'm a student that lives at a University without static local IP addresses, and where you can't port-forward for self-hosted servers. This script allows you to tunnel through a firewall on a port of your choice to negate the need to port-forward, and remotely check a device's IP address.

## Installation

1. Clone the repository
```bash
git clone https://github.com/OscarVanL/nomohead.git
cd nomohead
```
2. Install dependencies (Unix only)
```bash
sudo apt-get install wget curl unzip
```

3. Run the setup script.

* Linux:
```bash
./setup.sh
```
* Windows:

Launch Powershell
```powershell
./setup.ps1
```

Setup asks for the following parameters:
1. ngrok auth token - Go to https://dashboard.ngrok.com/get-started, create an account and enter the authtoken in part 3 "Connect your account".
2. Dweet Name - The name used to dweet your ngrok tunnel address to. Enter something you think is unique (i.e. not raspi). http://dweet.io/follow/<THIS NAME HERE>
3. Port - the port you want the tunnel to access, for example port 22 for remote SSH access.
4. Delay - The amount of time between pushes to dweet.io, I set this to 1 minute, but it could be less frequent.
5. ngrok server location - Pick the nearest location to you

Once all values are entered, a cron job is created that runs the nomohead script at boot.

## Dweets

In order to find your tunnel and IP information, you can go to 
```
http://dweet.io/follow/<DweetName>
```
where <DweetName> is the Tunnel ID you gave during Setup. 

## Limitations
Only one ngrok tunnel can exist for a free account. 
In my case, I wanted to open two tunnels. To bypass this limitation, I found that I can open one tunnel on the US ngrok server and the other on the EU server to bypasses this limitation.
