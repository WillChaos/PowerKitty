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
		[Int]$LPORT
	)

	return [pscustomobject]@{
		Name = $ListerName
		UUID = (New-Guid).Guid
		LHOST = $LHOST
		LPORT = $LPORT
	}
}