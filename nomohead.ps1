echo "Starting nomohead"

echo "Loading config..."

$pwd = Get-Location
echo "Current working directory is: $pwd"

if (-Not (Test-Path ".\config.cfg")) {
    throw "config.cfg could not be found. Exiting..."
}

echo "Reading settings"

$settings = Get-Content config.cfg

$DweetId = (($settings -match "dweet_id_tunnel") -split '=')[-1]
$NgrokPort = (($settings -match "port") -split '=')[-1]
$TunnelDelay = (($settings -match "tunnel_delay") -split '=')[-1]
$Server = (($settings -match "ngrok_server") -split '=')[-1]

echo "Dweet ID: $DweetId"
echo "Ngrok Tunnel Port: $NgrokPort"
echo "Refresh delay: $TunnelDelay"
echo "Server location: $Server"

echo "Starting ngrok..."


echo "`"$pwd\ngrok.exe`" tcp -region $Server $NgrokPort"
Start-Process "`"$pwd\ngrok.exe`"" -ArgumentList "tcp -region $Server $NgrokPort" -WindowStyle Minimized

Start-Sleep -s 1

while ($true) {
    $InternalIP = (get-netipaddress).ipaddress
    $ExternalIP = (Invoke-WebRequest -Uri https://api.ipify.org?format=json | ConvertFrom-Json).ip
    $TunnelAPIResponse = (Invoke-WebRequest -Uri http://localhost:4040/api/tunnels | ConvertFrom-Json)
    $ngrokTunnel = $TunnelAPIResponse.tunnels[0].public_url
    Invoke-WebRequest -Uri "http://dweet.io/dweet/for/$DweetId" -Method POST -Body "tunnel=$ngrokTunnel&internal_ip=$InternalIP&external_ip=$ExternalIP"
    Start-Sleep -s $TunnelDelay
}