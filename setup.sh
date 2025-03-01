#!/bin/bash

echo -e "\e[1m\e[44mWelcome to nomohead's setup script! \e[0m"

[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

echo ""

echo "Testing to see if ngrok is contained inside this folder..."

cd "$(dirname "${BASH_SOURCE[0]}")"
./ngrok > /dev/null

if [ $? != 0 ]; then
	echo "ngrok executable was not found inside nomohead folder. Starting download..."
	echo ""
	download=""
	zip=""
	case $(uname -m) in
		i386)   download="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.tgz" && tgz="ngrok-v3-stable-linux-386.tgz" && echo "Downloading archive for x86 Linux" ;;
		i686)   download="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.tgz" && tgz="ngrok-v3-stable-linux-386.tgz" && echo "Downloading archive for x86 Linux" ;;
		x86_64) download="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" && tgz="ngrok-v3-stable-linux-amd64.tgz" && echo "Downloading archive for x86_64 Linux" ;;
		arm*)    dpkg --print-architecture | grep -q "arm64" && download="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz" && tgz="ngrok-v3-stable-linux-arm64.tgz" && echo "Downloading archive for arm64 Linux" || download="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz" && tgz="ngrok-v3-stable-linux-arm.tgz" && echo "Downloading archive for arm32 Linux" ;;
	esac
	wget "$download"
	tar -xf "$tgz"
	echo "Download and extraction of ngrok executable complete"
	echo "Removing archive..."
	rm "$tgz"
else
	echo "ngrok executable found!"
fi

echo -e "Enter your ngrok authtoken (Go to \e[4m\e[107m\e[34mhttps://dashboard.ngrok.com/get-started\e[0m and copy this from 'Connect your account') : "
read user_authtoken

if [[ $user_authtoken == *" authtoken "* ]]; then
	$user_authtoken=${user_authtoken##*; }
fi

./ngrok authtoken $user_authtoken

echo "Enter the desired (unique) dweet name (this will be in the URL you can see your ngrok address at, eg: http://dweet.io/follow/<THIS NAME HERE> : "
read d_id_tun

echo "Enter the port you want to tunnel to. (Leave empty for default of 22) : "
read ngrok_port

if [ "$ngrok_port" == "" ]; then
	ngrok_port="22"
fi

echo "Enter the delay between refreshing dweet values (Leave empty for default of 1m) : "
read tun_delay

if [ "$tun_delay" = "" ]; then
	tun_delay="1m"
fi

echo "Enter the ngrok server location you wish to use [us (USA), eu (Europe), ap (Asia/Pacific), au (Australia), sa (South America), jp (Japan), in (India)] : "
read server

if [ "$server" == "us" ] || [ "$server" == "eu" ] || [ "$server" == "ap" ] || [ "$server" == "au" ] || [ "$server" == "sa" ] || [ "$server" == "jp" ] || [ "$server" == "in" ]; then
	echo "Selected ${server} as ngrok server"
else
	echo "Invalid server choice, setting to eu instead";
	server="eu"
fi

echo "Installing ngrok service"
ngrokconf=\
"version: \"2\"\n\
authtoken: $user_authtoken\n\
region: $server\n\
tunnels:\n\
  nomohead:\n\
    proto: tcp\n\
    addr: $ngrok_port"
echo -e "$ngrokconf" > ngrok.yml
command="${DIR}/ngrok service install --config ngrok.yml"

printf "dweet_id_tunnel=${d_id_tun}\nport=${ngrok_port}\ntunnel_delay=${tun_delay}\nngrok_server=${server}" > config.cfg

echo "Adding Cron job..."

DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

command="${DIR}/nomohead.sh"
job="@reboot bash $command"
echo "Adding to cron - ${job}"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

echo "Done. Reboot to finish installation."
