#
# Get_Listerner.psm1
#
Function Global:Get-Listerner()
{
	param
	(
		[Parameter()]
		[String]$UID,

		[Parameter()]
		[String]$Name,

		[Parameter()]
		[String]$LHOST,

		[Parameter()]
		[long]$LPORT,

	)

	$Global:ListernerPool | Where-Object {
		$_.UUID -like "*$UID*" -and
		$_.Name -like "*$Name*" -and
		$_.LHOST -like "*$LHOST*" -and
		$_.LPORT -like "*$LPORT*" 
	}
}