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
		[Long]$LHOST,

		[Parameter()]
		[short]$LPORT
	)

	# If global lister object doesnt exist,or is null - create one
	if(!($Global:ListernerPool)){
		$Global:ListernerPool = @()
	}

	# Create a template listerner object
	[pscustomobject]$obj@{
		Name  = $ListerName
		UUID  = (New-Guid).Guid
		LHOST = $LHOST
		LPORT = $LPORT
	}

	# add listerner psobject to array
	$Global:ListernerPool.Add($obj)

	# build a runspace
	$Runspace            = [runspacefactory]::CreateRunspace()
	$PowerShell          = [powershell]::Create()
	$PowerShell.runspace = $Runspace
	$Runspace.Open()

	[void]$PowerShell.AddScript({

		# Build a simple TCP listerner
		[console]::Title = ("Server: $LHOST : $LPORT")
		$endpoint        = new-object System.Net.IPEndPoint ($LHOST, $LPORT)
		$listener        = new-object System.Net.Sockets.TcpListener $endpoint
		$listener.start()
		$client          = $listener.AcceptTcpClient()

	})

	$AsyncObject = $PowerShell.BeginInvoke()
	$AsyncObject

	

	
}