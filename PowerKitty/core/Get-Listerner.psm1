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
		$_.UUID  -like "*$UID*"    -xor
		$_.Name  -like "*$Name*"   -xor
		$_.LHOST -like "*$LHOST*"  -xor
		$_.LPORT -like "*$LPORT*" 
	}
}