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
		[String]$LHOST,

		[Parameter()]
		[Long]$LPORT
	)

	# Create a template listerner object
	[pscustomobject]@{
		Name = $ListerName
		UUID = (New-Guid).Guid
		LHOST = $LHOST
		LPORT = $LPORT
	}
	# Build a simple TCP listerner
	[console]::Title = ("Server: $LHOST : $LPORT")
	$endpoint = new-object System.Net.IPEndPoint ($LHOST, $LPORT)
	$listener = new-object System.Net.Sockets.TcpListener $endpoint
	$listener.start()
	$client = $listener.AcceptTcpClient()

	
}