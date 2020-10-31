echo "Welcome to nomohead's setup script!"
echo ""
echo "Testing to see if ngrok is contained inside this folder..."

if (Test-Path ".\ngrok.exe") {
    echo "ngrok executable found!"
} else {
    echo "ngrok executable was not found inside nomohead folder. Starting download..."
    echo ""
    # Check if Windows is 32 or 64 bit.
    if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -eq "64-bit") {
        echo "Downloading Windows 64-bit ngrok executable"
        wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -OutFile ngrok-win.zip
    }
    else {
        echo "Downloading Windows 32-bit ngrok executable"
        wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-386.zip -OutFile ngrok-win.zip
    }
    echo "Download of ngrok archive complete"
    Expand-Archive -Path ngrok-win.zip -DestinationPath .
    echo "Extraction of ngrok archive complete"
}

$Authtoken = Read-Host -Prompt "Enter your ngrok authtoken (Go to https://dashboard.ngrok.com/get-started and copy this from 'Connect your account') "
if ([string]::IsNullOrEmpty($Authtoken)) {
    throw "Authtoken was blank"
}

# If the user puts in the whole ./ngrok authtoken TOKEN command, strip out just the TOKEN
if ($Authtoken -Match "authtoken") {
    $AuthTemp = $Authtoken -split ' '
    $Authtoken = $AuthTemp[-1]
}

echo "Token entered: $Authtoken"
echo "Registering authtoken with ngrok"
./ngrok authtoken $Authtoken

$DweetId = Read-Host -Prompt "Enter the desired (unique) dweet name (this will be in the URL you can see your ngrok address at, eg: http://dweet.io/follow/<THIS NAME HERE> "
if ([string]::IsNullOrEmpty($DweetId)) {
    throw "Dweet name was blank"
} else {
    echo "Dweet name entered: $DweetId"
}

$NgrokPort = Read-Host -Prompt "Enter the port you want to tunnel to. "
if ([string]::IsNullOrEmpty($NgrokPort)) {
    throw "Tunnel port was blank"
} else {
    echo "Tunnel port entered: $NgrokPort"
}

$TunnelDelay = Read-Host -Prompt "Enter the delay between refreshing dweet.io in seconds (Leave empty for default of 1 minute) "
if ($TunnelDelay -eq [string]::empty) {
    $TunnelDelay="60"
}
echo "Refresh delay entered: $TunnelDelay"

$Server = Read-Host -Propt "Enter the ngrok server location you wish to use [us (USA), eu (Europe), ap (Asia/Pacific), au (Australia), sa (South America), jp (Japan), in (India)] : "
$ValidServers = "us", "eu", "ap", "au", "sa", "jp", "in"
if ($Server -in $ValidServers) {
    echo "Selected $Server as ngrok server"
} else {
    throw "Invalid Ngrok server choice. Select from us, eu, ap, au, sa, jp, in."
}

echo "Creating Config file"

if (Test-Path "config.cfg") {
    $response = Read-Host -Prompt "Config file already exists. Would you like to delete it and generate a new one? [y/n]"
    if ($response -Match "y") {
        Remove-Item "config.cfg"
    } elseif ($response -Match "n") {
        throw "You decided not to write to the Config, so we're done..."
    } else {
        throw "Invalid answer."
    }
    
}

echo "Config saved"
Set-Content -Path "config.cfg" -Value "dweet_id_tunnel=$DweetId`nport=$NgrokPort`ntunnel_delay=$TunnelDelay`nngrok_server=$Server"

# Todo: Test the TaskScheduler works...
$response = Read-Host -Prompt "Would you like to setup a TaskScheduler job to automatically run ngrok at startup? [y/n]"
if ($response -Match "y") {
    echo "Creating TaskScheduler job..."
    $pwd = Get-Location
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
    $action = New-ScheduledJob -Trigger $trigger -FilePath "$pwd\nomohead.ps1" -Name nomohead
}

echo "Finished! Starting nomohead..."

.\nomohead.ps1