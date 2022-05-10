#
# New_Listerner.psm1
#
Function Global:New-Listerner()
{
	param
	(
		[Parameter()]
		[String]$ListerName,

		[Parameter()]
		[system.net.ipaddress]$LHOST = [system.net.ipaddress]::Loopback,

		[Parameter()]
		[short]$LPORT,

		[Parameter()]
		[String]$PSK
	)

	# If global lister object doesnt exist,or is null - create one
	if(!($Global:ListernerPool)){
		$Global:ListernerPool = @()
	}

	# Build a simple TCP listerner
	[console]::Title = ("Server: $LHOST : $LPORT")
	$endpoint        = new-object System.Net.IPEndPoint ($LHOST, $LPORT)
	$listener        = new-object System.Net.Sockets.TcpListener $endpoint
	$listener.start()

	# Create a template listerner object
	$obj = [pscustomobject]@{
		Name  = [String]$ListerName
		UUID  = [String](New-Guid).Guid
		LHOST = $LHOST
		LPORT = $LPORT
		RAWSOCK = $listener
		AGENTCOUNT = [INT]0
		RAWAGENT = $null
	}

	# add listerner psobject to array
	$Global:ListernerPool += $obj

	# add a runspace here (yes we are nesting)
	# add it once the listerner works. when its working, we can shove it into the background so the powershell terminal is free again.

	# continue accepting socket connections until object no longer exists
	while(Get-Listerner -UUID ($obj.UUID))
	{
		
		if($client = $listener.AcceptTcpClient())
		{
			
			"sock!"

			# add agent to listerner
			#$thisListerner = Get-Listerner -UUID ($obj.UUID.toString())
			#$agentCount    = $thisListerner.AGENTCOUNT++
			#$agents        = $thisListerner.RAWAGENT += $client
			# make this work from pipeline: (get lister | set listerner)
			#Set-Listerner -RAWAGENT $agents -AGENTCOUNT $agentCount -UUID $obj.UUID
		    
			# upgrade agent (maybe auth - tty etc)
			
			# build a runspace
			$Runspace            = [runspacefactory]::CreateRunspace()
			$PowerShell          = [powershell]::Create()
			$PowerShell.runspace = $Runspace
			$Runspace.Open()
			$runspace.SessionStateProxy.SetVariable('C', $client)
			[void]$PowerShell.AddScript({
				
				$Stream = $C.GetStream()
				$StreamWriter = New-Object System.IO.StreamWriter($Stream)
				$StreamReader = New-Object System.IO.StreamReader($Stream)

				# if PSK matches, payload

				# TODO: We are working on the below.
				# we can send data to the client, but when the client sends us data (ReadLine() we can check it agaisnt the PSK)
				# since its ina  runspace itsd hard to see the error or whats going on. we need to remove the runspace, and then get it to work
				# i image we need to encode it and then decode when reading?


				# below is the ps client im using with the lister: New-Listerner -ListerName test -LPORT 9629 -PSK 123
				<#
				$PSK = "123"

				$tcp = New-Object System.Net.Sockets.TcpClient; 
				$tcp.connect('127.0.0.1', 9629); 

				$tcpStream = $tcp.GetStream()
				$reader = New-Object System.IO.StreamReader($tcpStream)
				$writer = New-Object System.IO.StreamWriter($tcpStream)
				$writer.WriteLine($PSK);
				$reader.ReadLine()
				#>

				if($StreamReader.ReadLine() -eq $PSK)
				{
					$StreamWriter.WriteLine("get-service") | Out-Null

				}
				# else, gtfo
				else
				{
					$Result = [System.Windows.MessageBox]::Show($StreamReader.ReadLine(),"X",1)
					$StreamWriter.WriteLine("PowerKitty: Hisss!!!") | Out-Null
				}

				
				$StreamWriter.Close()
				$StreamReader.Close()
			})

			$AsyncObject = $PowerShell.BeginInvoke()
			

		}
		
		# small sleep to not thrash CPU
	    Start-Sleep -Milliseconds 100
		
	}
	$listener.Stop();
	

}