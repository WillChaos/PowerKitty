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
		[Object]$UUID,

		# modifiable 
        [Parameter()]
		[Object]$RAWSOCK,

		# modifiable 
		[Parameter()]
		[INT]$AGENTCOUNT,

		# modifiable 
		[Parameter()]
		[object]$RAWAGENT
    )



	Process
	{
		# Get the listerner based on the UUID we are processing
		$thisListerner = Get-Listerner -UUID $UUID
		$thisListerner.RAWSOCK    = ($listerner.RAWSOCK    += $RAWSOCK)
		$thisListerner.AGENTCOUNT = ($listerner.AGENTCOUNT += $AGENTCOUNT)
		$thisListerner.RAWAGENT   = ($listerner.RAWAGENT   += $RAWAGENT)
	}
		

 }	
 