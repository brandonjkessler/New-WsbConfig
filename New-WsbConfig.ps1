[CmdletBinding()]
param(
   [parameter(Mandatory=$false,HelpMessage='The path you want to use for your Host. This will be where all files and folders are placed.')]
   [string]
   $WorkingDirectory = "$PSScriptRoot",
   [parameter(Mandatory=$false,HelpMessage='Comma-Seperated list of other folders to create.')]
   [string]
   $CustomDirectories,
   [parameter(Mandatory,HelpMessage='Name of the file for output.')]
   [string]
   $WsbName
)


##------------------------------------------------------
##------------------ Create Folders --------------------
##------------------------------------------------------
##-- Creates folders on the host device to map

##--- Working Directory
Write-Verbose -Message "Checking for existence of $WorkingDirectory"

if((Test-Path -Path $WorkingDirectory) -ne $true){
   try{
      Write-Verbose -Message "Creating directory $WorkingDirectory"
      New-Item -ItemType Directory -Path $WorkingDirectory
   } catch {
      $ErrorMessage = $_.Exception.Message
	   Write-Error $ErrorMessage
      $FailedItem = $_.Exception.ItemName
	   Write-Error $FailedItem
   }
}

##--- Software Installs
$SoftwareInstallDir = "$WorkingDirectory\Software Installs"

Write-Verbose -Message "Checking for $SoftwareInstallDir."
if((Test-Path -Path "$SoftwareInstallDir") -ne $true){
   try{
      Write-Verbose -Message "Creating directory $SoftwareInstallDir"
      New-Item -Path "$SoftwareInstallDir" -ItemType Directory
   } catch {
      $ErrorMessage = $_.Exception.Message
	   Write-Error $ErrorMessage
      $FailedItem = $_.Exception.ItemName
	   Write-Error $FailedItem
   }
}
##--- Software install Script
$SoftwareInstallFile = "$SoftwareInstallDir\Install-WsbSoftware.ps1"

Write-Verbose -Message "Checking for $SoftwareInstallFile"
if((Test-Path -Path "$SoftwareInstallFile") -ne $true){
   try{
      Write-Verbose -Message "Creating file $SoftwareInstallFile"
      New-Item -Path "$SoftwareInstallFile" -ItemType File
   } catch {
      $ErrorMessage = $_.Exception.Message
	   Write-Error $ErrorMessage
      $FailedItem = $_.Exception.ItemName
	   Write-Error $FailedItem
   }
}

##--- Create setup.cmd file
$SetupCommandFile = "$SoftwareInstallDir\setup.cmd"

Write-Verbose -Message "Checking for $SetupCommandFile"
if((Test-Path -Path "$SetupCommandFile") -ne $true){
   try{
      Write-Verbose -Message "Creating file $SetupCommandFile"
      New-Item -Path "$SetupCommandFile" -ItemType File
   } catch {
      $ErrorMessage = $_.Exception.Message
	   Write-Error $ErrorMessage
      $FailedItem = $_.Exception.ItemName
	   Write-Error $FailedItem
   }
}


##--- Custom Directories
[array]$CustomDirArr = $CustomDirectories.Split(",").Trim()

if(($null -ne $CustomDirectories) -and ($CustomDirectories -ne '')){
   $CustomDirArr | ForEach-Object{
      Write-Verbose -Message "Checking if $($_) already exist."
      if((Test-Path -Path "$WorkingDirectory\$($_)") -ne $true){
         try{
            Write-Verbose -Message "Creating directory $($_)"
            New-Item -Path $WorkingDirectory -ItemType Directory -Name $_
         } catch {
            $ErrorMessage = $_.Exception.Message
            Write-Error $ErrorMessage
            $FailedItem = $_.Exception.ItemName
            Write-Error $FailedItem
         }
      }
   
   }
}


##------------------------------------------------------
##------------------ XML Variables ---------------------
##------------------------------------------------------
##-- Creates Variables to hold XML values
##-- <MappedFolder>Folder Path</MappedFolder>
##-- <Command>Command Prompt command</Command>

$WsbXmlBegin = @"
<Configuration>
<VGpu>Default</VGpu>
<Networking>Default</Networking>
"@

$WsbXmlEnd = @"
</Configuration>
"@

$WsbXmlMappedFolderBegin = @"
<MappedFolders>
"@

$WsbXmlMappedFolderEnd = @"
</MappedFolders>
"@

$WsbXmlLogonBegin = @"
<LogonCommand>
   <Command>powershell.exe -ExecutionPolicy ByPass -NoProfile -WindowStyle Normal -File "C:\Users\WDAGUtilityAccount\Desktop\$(Split-Path -Path $WorkingDirectory -Leaf)\Software Installs\Install-WsbSoftware.ps1"</Command>
"@

$WsbXmlLogonEnd = @"
</LogonCommand>
"@



##------------------------------------------------------
##-------------- Create the Config File ----------------
##------------------------------------------------------

##-- Replace the .wsb extension if present
$WsbName = $WsbName.Replace('.wsb','')

##-- Create file and begin
$WsbFile = "$WorkingDirectory\$($WsbName).wsb"
Write-Verbose -Message "Checking for $WsbName in $WorkingDirectory"
if((Test-Path -Path "$WsbFile") -eq $true){
   try{
      Write-Warning -Message "$WsbFile already exists. Creating a backup."
      Move-Item -Path "$WsbFile" -Destination "$($WsbFile).old" -Force
   } catch {
      $ErrorMessage = $_.Exception.Message
      Write-Error $ErrorMessage
      $FailedItem = $_.Exception.ItemName
      Write-Error $FailedItem
   }
   
}
try{
   Write-Verbose -Message "Creating configuration file $($WsbName).wsb in $WorkingDirectory."
   New-Item -Path $WorkingDirectory -ItemType File -Name "$($WsbName).wsb"
} catch {
   $ErrorMessage = $_.Exception.Message
   Write-Error $ErrorMessage
   $FailedItem = $_.Exception.ItemName
   Write-Error $FailedItem
}


##-- Add XMls
$WsbXmlBegin | Out-File -FilePath $WsbFile -Append -Encoding utf8
$WsbXmlMappedFolderBegin | Out-File -FilePath $WsbFile -Append -Encoding utf8

$CustomDirArr | ForEach-Object{
@"
   <MappedFolder>
      <HostFolder>$($WorkingDirectory)\$($_)</HostFolder>
      <ReadOnly>false</ReadOnly>
   </MappedFolder>
"@ | Out-File -FilePath $WsbFile -Append -Encoding utf8
}

$WsbXmlMappedFolderEnd | Out-File -FilePath $WsbFile -Append -Encoding utf8
$WsbXmlLogonBegin | Out-File -FilePath $WsbFile -Append -Encoding utf8
$WsbXmlLogonEnd | Out-File -FilePath $WsbFile -Append -Encoding utf8
$WsbXmlEnd | Out-File -FilePath $WsbFile -Append -Encoding utf8


