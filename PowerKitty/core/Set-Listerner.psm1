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
		$RAWSOCK,

		# modifiable 
		[Parameter()]
		$AGENTCOUNT,

		# modifiable 
		[Parameter()]
		$RAWAGENT
    )



	Process
	{
		# Get the listerner based on the UUID we are processing
		$thisListerner = Get-Listerner -UUID $UUID
		$thisListerner.RAWSOCK    += $RAWSOCK
		$thisListerner.AGENTCOUNT += $AGENTCOUNT
		$thisListerner.RAWAGENT   += $RAWAGENT
	}
		

 }	
 