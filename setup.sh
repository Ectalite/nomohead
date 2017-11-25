#!/bin/bash
echo "Creating config file..."

echo "Enter the location of ngrok: "
read ngrok_loc

echo "Enter the Dweet ID for IP Address: "
read d_id_ip

echo "Enter the Dweet ID for Tunnel (leave empty to use the same as IP)"
read d_id_tun

if [ "$dweet_id_tunnel" = "" ]; then
	d_id_tun=$d_id_ip
fi

echo "Enter the delay between refreshing dweet values (Empty for default of 1m): "
read tun_delay

if [ "$tun_delay" = "" ]; then
	tun_delay="1m"
fi

echo "Enter the ngrok server location you wish to use [us, eu (Europe), ap (Asia/Pacific), au (Australia)]: "
read server

if [ "$server" -ne "us" ] || [ "$server" -ne "eu" ] || [ "$server" -ne "ap" ] || [ "$server" -ne "au" ]; then
	echo "Invalid server choice, setting to eu instead"
	server="eu"

printf "ngrok_location=${ngrok_loc}\ndweet_id_ip=${d_id_ip}\ndweet_id_tunnel=${d_id_tun}\ntunnel_delay=${tun_delay}\nngrok_server=${server}" > config.cfg

echo "Adding Cron job..."

DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"


command="${DIR}/nomohead.sh"
job="@reboot bash $command"
echo "Adding to cron - ${job}"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

echo "Done."