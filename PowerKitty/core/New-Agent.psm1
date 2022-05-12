#
# New_Agent.psm1
#
Function Global:New-Agent()
{
    [CmdletBinding()]
    param
    (
		# read only
		[Parameter()]
		[ValidateSet("Staged","Stageless")]
		[Object]$Type,

		[Parameter()]
		[String]$LHOST,

		[Parameter()]
		[INT]$LPORT
    )



	Process
	{
		if($Type -eq "Staged")
		{
			"Oneliner here"
		}

		if($Type -eq "Stageless")
		{
			
		}
		
	}
		

 }	