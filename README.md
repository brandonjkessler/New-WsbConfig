# Synopsis
Create a custom Windows Sandbox Config File

# Description
Creates a custom `.wsb` file based on inputs to the script. Also creates a `Software Installs` folder in a working directory and then creates an `Install-WsbSoftware.ps1` file. Add all the necessary install scripts to this file.

# Parameters
## WorkingDirectory
- String
- Not Mandatory
- Defaults to `$PSScriptRoot`
- Determines where all the other folders are setup.

## CustomDirectories
- string
- Not Mandatory
- No default
- Use a list of Comma-seperated folders to create. These will all be placed in the `WorkingDirectory`

## WsbName
- String
- Mandatory
- Name of the config file.

# Examples
`New-WsbConfig.ps1 -WorkingDirectory "D:\Windows Sandbox" -CustomDirectories "Downloads, Testing, App1" -WsbName "TestApp1"`

# References
[Customize Windows Sandbox](https://techcommunity.microsoft.com/t5/itops-talk-blog/customize-windows-sandbox/ba-p/2301354)
[Windows sandbox and Powershell : how to make script executable at startup](https://stackoverflow.com/questions/73189210/windows-sandbox-and-powershell-how-to-make-script-executable-at-startup)