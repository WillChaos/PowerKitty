#
# Get_Listerner.psm1
#
Function Global:Get-Listerner()
{
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[String]$UUID,

		[Parameter()]
		[String]$Name,

		[Parameter()]
		[String]$LHOST,

		[Parameter()]
		[long]$LPORT

	)

	$Global:ListernerPool | Where-Object {
		$_.UUID  -like "*$UUID*"   -xor
		$_.Name  -like "*$Name*"   -xor
		$_.LHOST -like "*$LHOST*"  -xor
		$_.LPORT -like "*$LPORT*" 
	}
}