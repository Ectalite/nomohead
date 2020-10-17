#!/bin/bash
# nomohead.sh
echo "Loading config..."

#Current directory (nomohead folder)
DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

if [ ! -e "${DIR}/config.cfg" ]; then
	echo "Config file does not exist, have you ran setup.sh yet? Aborting startup" | tee error.log
	exit 1
fi

. "${DIR}/config.cfg"

echo "Starting ngrok..."

#Creates command to run ngrok using defined directory in setup.sh (Eg: ~/Downloads/ngrok)
COMMAND=("${DIR}/ngrok" tcp -region "${ngrok_server}" "${port}")

"${COMMAND[@]}" > /dev/null &

#Sleeps for delay defined in setup.sh
sleep $tunnel_delay

while true
do
	#Gets the internal IP
	IP="$(hostname -I)"
	#Gets the external IP
	EXTERNALIP="$(curl -s https://canihazip.com/s )"

	echo "Dweeting IP... "

	TUNNEL="$(curl -s http://localhost:4040/api/tunnels)"
	echo "${TUNNEL}" > tunnel_info.json
	#Gets the tunnel's address and port
	TUNNEL_TCP=$(grep -Po 'tcp:\/\/[^"]+' ./tunnel_info.json )

	#Pushes all this information to dweet.io
	curl -d "tunnel=${TUNNEL_TCP}&internal_ip=${IP}&external_ip=${EXTERNALIP}" http://dweet.io/dweet/for/${dweet_id_tunnel}
	sleep $tunnel_delay
done
