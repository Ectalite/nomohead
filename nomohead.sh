#!/bin/bash
# nomohead.sh
echo "Loading config..."

#Current directory (nomohead folder)
DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

. "${DIR}/config.cfg"

echo "Starting ngrok..."

#Creates command to run ngrok using defined directory in setup.sh (Eg: ~/Downloads/ngrok)
#This creates it on the EU server and allows us to use ssh through the tunnel
COMMAND=("${ngrok_location}" tcp -region eu 22) 

"${COMMAND[@]}" 2> /dev/null &

#Sleeps for delay defined in setup.sh
sleep $tunnel_delay

while true
do
	#Gets the internal IP
	IP="$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')"
	#Gets the external IP
	EXTERNALIP="$(curl https://canihazip.com/s )"

	echo "Dweeting IP... "

	TUNNEL="$(curl http://localhost:4040/api/tunnels)"
	echo "${TUNNEL}" > tunnel_info.json
	#Gets the tunnel's address and port
	TUNNEL_TCP=$(grep -Po 'tcp:\/\/([\S]*?)"' ./tunnel_info.json )

	#Pushes all this information to dweet.io
	wget --post-data="ssh_tunnel=${TUNNEL_TCP}&internal_IP=${IP}&external_IP=${EXTERNALIP}" http://dweet.io/dweet/for/${dweet_id_tunnel} -O /dev/null
	sleep $tunnel_delay
done
