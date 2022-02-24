#requires -version 5
<#
.SYNOPSIS
  
.DESCRIPTION
  
.PARAMETER 
  
.INPUTS
  
.OUTPUTS
  
.NOTES
  Author:         WillBambi
  Creation Date:  2022/02/24
  Purpose/Change: Fuck shit up, my way, on my time, with my preference of shell.
  
.EXAMPLE
  
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
$CurrentOS = [System.Environment]::OSVersion.Platform

#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Location for WPS ZIP Master in gitgub
$MasterLocation = "https://github.com/WillChaos/PowerKitty/master.zip"
    
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Invoke-Banner
{
    # Simple banner
    Write-Host " 
    
          _____                         _  ___ _   _         
         |  __ \                       | |/ (_) | | |        
         | |__) |____      _____ _ __  | ' / _| |_| |_ _   _ 
         |  ___/ _ \ \ /\ / / _ \ '__| |  < | | __| __| | | |
         | |  | (_) \ V  V /  __/ |    | . \| | |_| |_| |_| |
         |_|   \___/ \_/\_/ \___|_|    |_|\_\_|\__|\__|\__, |
                                                        __/ |
                                                       |___/ 

    " -ForegroundColor Green

}

Function Configure-PreReqs
{
# Configure TLS support for github
    try
    {
        ([Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12) | Out-Null
        Write-Host "[+] Configured TLS 1.2 Channels for Git communication" -ForegroundColor DarkMagenta

    }
    catch
    {
        Write-Host "[!] Failed to build TLS 1.2 Channel Support" -ForegroundColor DarkRed
    }
}

Function Invoke-Loader
{
  Write-Host "[+] Staging self in memory" -ForegroundColor DarkMagenta
  [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

  # download zip - store content as bytes (in mem)
  $ZipBytes   = (Invoke-WebRequest -Uri $MasterLocation).content
  
  # build a Zip object, and write the bytes into the zip object (in mem)
  $ZipStream  = New-Object System.IO.Memorystream
  $ZipStream.Write($ZipBytes,0,$ZipBytes.Length)
  $ZipArchive = New-Object System.IO.Compression.ZipArchive($ZipStream)
  $ZippedContent = $ZipArchive.Entries
  
  # opperate on each item in the zip
  foreach($Zippeditem in $ZippedContent)
  {
    # if the zip items contain a powershell file or module, do the below (that isnt the main module
    if(($Zippeditem.FullName -like "*Ps1") -or ($Zippeditem.FullName -like "*psm1") -and ($Zippeditem.FullName -notlike "*PowerKitty.psm1"))
    {
        # open zip item type in memory - store string based contents into a file
        $EntryReader = New-Object System.IO.StreamReader($Zippeditem.Open())
        $ItemContent  = $EntryReader.ReadToEnd()

        # handle Os dependant scripts - import only as NIX script if specified
        if($ItemContent -like "*OS:NIX*" -and $CurrentOS -notlike "Unix")
        {
            # The module is a linux module but we are on windows. skip.
        }
        if($ItemContent -like "*OS:WIN*" -and $CurrentOS -notlike "Win32NT")
        {
            # The module is a Windows module but we are on Linux. skip.
        }
        else
        {
            # We either havent sepcified the OS type in the module, or - 
            # We have specified it and we are on the correct OS. either way, Import!
            Write-Host "-[>] Importing module: "$Zippeditem.FullName  -ForegroundColor DarkGray
            Invoke-Expression $ItemContent
        } 
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Invoke-Banner
Configure-PreReqs
Invoke-Loader
