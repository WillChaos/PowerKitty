#
# debug.ps1
#

# import modules
(Get-ChildItem -Path ".\PowerKitty\core\" -Recurse).FullName | Import-Module -Force

# thing to test (add breakpoints in the relevant function here)
New-Listerner -ListerName "fgeefdf" -LPORT 1234 -PSK "TEST" -StageType Staged 

# then view the stage port :)