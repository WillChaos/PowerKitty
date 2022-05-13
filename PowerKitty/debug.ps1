#
# debug.ps1
#

# import modules
(Get-ChildItem -Path ".\PowerKitty\core\" -Recurse).FullName | Import-Module -Force

# thing to test (add breakpoints in the relevant function here)
New-Listerner -ListerName "Test123" -LPORT 7777 -PSK "TEST" -StageType Staged -StageLPORT 8080
