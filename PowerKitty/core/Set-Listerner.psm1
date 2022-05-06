#
# Set_Listerner.psm1
#

Function Global:Set-Listerner()
{
    [CmdletBinding()]
    param
    (
		# read only
		[Parameter()]
		[Object]$UUID

		# modifiable 
        [Parameter()]
		[Object]$RAWSOCK

		# modifiable 
		[Parameter()]
		[long]$AGENTCOUNT,

		# modifiable 
		[Parameter()]
		[object]$RAWAGENT,
    )

	Process
	{
		# Get the listerner based on the UUID we are processing
		$thisListerner = Get-Listerner -UUID $UUID

		$thisListerner.RAWSOCK    = ($thisListerner.RAWSOCK    += $RAWSOCK)
		$thisListerner.AGENTCOUNT = ($thisListerner.AGENTCOUNT += $AGENTCOUNT)
		$thisListerner.RAWAGENT   = ($thisListerner.RAWAGENT   += $RAWAGENT)
	}

 }