#Remote Installation on all LAN computers
$Choice = Read-Host -Prompt "Would you like to insert the list of computer names by yourself or have it prepared by the tool? Please type y or n"
if($choice -eq 'y') {
    Write-Host "Generating list of the computers in your domain based on your AD database."
    $PCtxtPath = Read-Host -Prompt "Please insert the path in where the .txt file with the computer names will be"
    Get-ADComputer -Filter * -Properties Name | Select-Object Name | Out-File $PCtxtPath 
    $Computers = $PCtxtPath
}
else {
    Write-Host "You chose to provide your own name list of domain computers. Please type in the path to the file below or type in all the names, separated by a comma."
    $Computers = Read-Host -Prompt "Insert the path/ names"
}
#The user chooses wether or not to have a list of domain PC's automatically generated or not. If they choose not too they are asked to insert it manually via text file or list.
$SourceFile = Read-Host -Prompt "Insert the path to the .msi file"
#User inserts the path to the msi file that will be installed on all provided domain PCs.
foreach($Computer in $Computers) {
    $ComputerStatus = Test-NetConnection -ComputerName $Computers -count 2 -Quiet
    #Checking each PC to see if it's online, if it is the script will continue with installation.
    if($ComputerStatus -eq "True"){
        Invoke-WmiMethod -ComputerName $Computers -Path win32_process -Name create -ArgumentList "powershell.exe -command msiexec.exe /i $SourceFile /quiet /norestart"
        #Here is where the msi process is invoked  
        Write-Host "Starting Installation Proccess"
        Start-Sleep -Seconds 35
        #Stopping the script for 35 seconds to make sure the command has gone through successfully   
    }
    else {
        Write-Host "PC is offline. moving to next PC."
        }   
}
Write-Host "The script will now check if the installation was successful. Would you like to produce a log file with the conformations?"
$LogFile = Read-Host -Prompt "Please type y or n"
#The user chooses whether or not to have the conformation printed into a file. I they choose yes they will be requiered to name it.
if($LogFile -eq 'y') {
    Write-Host "The log file will be produced and saved in the following location:" $HOME\LogFile.txt
    $LogFileName = Read-Host -Prompt "Insert a name for the log file. Please type it in this format: 'filename.txt'"
    $LogFilePath = $HOME\$LogFileName
    #The path in which the file will be created. The variable 'home' will make it suitable for use in any windows PC.
    foreach($Computer in $Computers) {
    Get-CimInstance -ComputerName $Computers -ClassName win32_product -ErrorAction SilentlyContinue | Select-Object PSComputerName, Name, PackageName, InstallDate -First 1| Write-Output >> $LogFilePath 
    $Software = Read-Host -Prompt "Please insert the name of the software you installed."
    $SoftWhere = Select-String -Path $LogFilePath -Pattern -like $Software
    if($null -ne $SoftWhere) {
        Write-Host "Installation completed successfully on" $Computer
    }
    else {
        Write-Host "Could not install package. Try checking connectivity and account premmisions."
    }
    }
    #A loop for extracting log info on every PC that was provided. Only the relevant info will be displayed. 1st line of log only, since that is the last program that wa sinstalled, prevent overload of info.
    Start-Sleep -Seconds 10
    Get-Content -Path $LogFilePath
}
else {
    Write-Host "The conformation will be printed on screen. No file created."
    foreach($Computer in $Computers) {
        Get-CimInstance -ComputerName $Computers -ClassName win32_product -ErrorAction SilentlyContinue | Select-Object PSComputerName, Name, PackageName, InstallDate -First 1  
        $Software = Read-Host -Prompt "Please insert the name of the software you installed."
        $SoftWhere = Get-CimInstance -ComputerName $Computers -ClassName win32_product -ErrorAction SilentlyContinue | Select-Object PSComputerName, Name, PackageName, InstallDate -First 1 | Select-String -Path $LogFilePath -Pattern -like $Software
        if($null -ne $SoftWhere) {
            Write-Host "Installation completed successfully on" $Computer
        }
        else {
            Write-Host "Could not install package. Try checking connectivity and account premmisions."
            break
        }
    }
}