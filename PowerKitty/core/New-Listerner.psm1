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
		[short]$LPORT
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
	while(Get-Listerner -UUID ($obj.UUID.toString()))
	{

		# begin accepting connections
			$client          = $listener.AcceptTcpClient()
			
			# add agent to listerner
			$thisListerner = Get-Listerner -UUID ($obj.UUID.toString())
			$agentCount    = $thisListerner.AGENTCOUNT++
			$agents        = $thisListerner.RAWAGENT += $client
			Get-Listerner -UUID ($obj.UUID.toString()) | Set-Listerner -RAWAGENT $agents  -AGENTCOUNT $agentCount

			
			# upgrade agent (maybe auth - tty etc)
			$Stream = $client.GetStream()
			$StreamWriter = New-Object System.IO.StreamWriter($Stream)
			$StreamWriter.WriteLine("TEST") | Out-Null
		    $StreamWriter.Close()
			# small sleep to not thrash CPU
			Start-Sleep -Milliseconds 100




		# build a runspace
		$Runspace            = [runspacefactory]::CreateRunspace()
		$PowerShell          = [powershell]::Create()
		$PowerShell.runspace = $Runspace
		$Runspace.Open()
		[void]$PowerShell.AddScript({

			
		})

		$AsyncObject = $PowerShell.BeginInvoke()
	}
	$listener.Stop();

	


	
}