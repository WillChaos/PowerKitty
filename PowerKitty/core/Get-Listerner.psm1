#
# Get_Listerner.psm1
#
Function Global:Get-Listerner()
{

	param
	(
		[Parameter()]
		[String]$UID

	)

	$Global:ListernerPool | Where-Object {$_.UUID -like "*$UID*"}

}