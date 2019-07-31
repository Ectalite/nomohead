#!/bin/bash

echo -e "\e[1m\e[44mWelcome to nomohead's setup script! \e[0m"

echo ""

echo "Testing to see if ngrok is contained inside this folder..."

cd "$(dirname "${BASH_SOURCE[0]}")"
./ngrok > /dev/null

if [ $? != 0 ]; then
	echo "ngrok executable was not found inside nomohead folder. Starting download..."
	echo ""
	wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
	unzip ngrok-stable-linux-arm.zip 1> /dev/null &
	echo "Download and unzip of ngrok executable complete"
else
	echo "ngrok executable found!"
fi


echo "Enter the desired (unique) dweet name (this will be in the URL you can see your ngrok address at, eg: http://dweet.io/follow/<THIS NAME HERE> "
read d_id_tun

echo "Enter the port you want to tunnel to. (Leave empty for default of 22)"
read ngrok_port

if [ "$ngrok_port" == "" ]; then
	ngrok_port="22"
fi

echo "Enter the delay between refreshing dweet values (Leave empty for default of 1m): "
read tun_delay

if [ "$tun_delay" = "" ]; then
	tun_delay="1m"
fi

echo "Enter the ngrok server location you wish to use [us (USA), eu (Europe), ap (Asia/Pacific), au (Australia), sa (South America), jp (Japan), in (India)]: "
read server

if [ "$server" == "us" ] || [ "$server" == "eu" ] || [ "$server" == "ap" ] || [ "$server" == "au" ] || [ "$server" == "sa"] || [ "$server" == "jp" ] || [ "$server" == "in" ]; then
	echo "Selected ${server} as ngrok server"
else
	echo "Invalid server choice, setting to eu instead"
	server="eu"
fi

printf "dweet_id_tunnel=${d_id_tun}\nport=${ngrok_port}\ntunnel_delay=${tun_delay}\nngrok_server=${server}" > config.cfg

echo "Adding Cron job..."

DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

command="${DIR}/nomohead.sh"
job="@reboot bash $command"
echo "Adding to cron - ${job}"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

echo "Done."
