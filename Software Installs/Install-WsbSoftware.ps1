[cmdletbinding()]
param(

)

##--------------- Execution Policy ---------------##
Write-Verbose -Message "Setting Execution Policy to Unrestricted for the machine."
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force