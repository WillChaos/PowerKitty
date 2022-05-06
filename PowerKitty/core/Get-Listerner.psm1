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
		[long]$LPORT

	)

	$Global:ListernerPool | Where-Object {
		$_.UUID -like "*$UID*" -or
		$_.Name -like "*$Name*" -or
		$_.LHOST -like "*$LHOST*" -or
		$_.LPORT -like "*$LPORT*" 
	}
}