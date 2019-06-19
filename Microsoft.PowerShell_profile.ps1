Write-Host "loading profile..." -NoNewline

#region Transcript

$PSTranscriptDir = "$env:USERPROFILE\Documents\WindowsPowerShell\transcripts\$(Get-Date -Format yyyy)\$(Get-Date -Format MM)\$(Get-Date -Format dd)"
$TranscriptName = "$(get-date -Format yyyyMMdd-hhmmss).txt"

New-Item -ItemType Directory -Path $PSTranscriptDir -Force | Out-Null
Start-Transcript "$($PSTranscriptDir)\$($TranscriptName)" | Out-Null

#Write-Host "Transcript Directory: $($PSTranscriptDir)"
#Write-Host "Transcript started: $($TranscriptName)"

#endregion Transcript

#region Tab Completion Behavior

Set-PSReadlineKeyHandler -Chord Tab -Function Complete
Set-PSReadlineKeyHandler -Chord CTRL+Tab -Function TabCompleteNext
Set-PSReadlineOption -ShowToolTips -BellStyle Visual

#endregion Tab Completion Behavior



#region shortcuts

function gui()
{
	explorer $(get-location).toString()
}

function reload()
{    
    split.target $(get-location).toString() $false
    Stop-Process -Id $PID
}

function goAdmin()
{
    split.target $(get-location).toString() $true
    Stop-Process -Id $PID
}

function isAdmin()
{
    return (New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)    
}

function color($scheme)
{
    if($scheme -eq $null)
    {
        $scheme = "default"
    }
    
    switch ($scheme)
    {
        "default" 
        {
            $env:console_bg = "DarkBlue"
            $env:console_fg = "White"         
        }
        "admin" 
        {
            $env:console_bg = "black"
            $env:console_fg = "green"         
        }
        "ssh"
        {
            $env:console_bg = "black"
            $env:console_fg = "white"
        }
    
    }
    $console = (Get-Host).UI.RawUI
    $console.BackgroundColor = $env:console_bg
    $console.ForegroundColor = $env:console_fg
    Clear-Host
}

function PSVersion ()
{
    write-host PowerShell Version $PSVersionTable.PSVersion
}

$npp = "C:\Program Files (x86)\Notepad++\notepad++.exe"

#Open file in NotePad++
function NPP ($file)
{
    if (Test-Path -Path $npp)
    {
        start-process -FilePath $npp -ArgumentList $file
    } else {

        "Notepad++ is not installed"
    }
}

function HostFileOpen()
{
    $hostsPath = "$env:windir\System32\drivers\etc\hosts"
    ise $hostsPath
}


function ProfileView()
{
	get-content $PROFILE | write-host 
}

function ProfileEditLocal()
{
	ise $PROFILE | write-host 
}

Function ProfileViewGitPage ()
{
	start-process "https://github.com/madrum/PowershellProfile/blob/master/Microsoft.PowerShell_profile.ps1"
}

function ProfileUpdateFromGitHub ()
{
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/madrum/PowershellProfile/master/Microsoft.PowerShell_profile.ps1" -outfile $PROFILE
	#Invoke-WebRequest -Uri "https://raw.githubusercontent.com/madrum/PowershellProfile/master/Microsoft.PowerShell_profile.ps1" | Select-Object -Expand Content | Out-File $PROFILE
	#(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/madrum/PowershellProfile/master/Microsoft.PowerShell_profile.ps1").Content | Out-File $PROFILE
}

function TranscriptsViewFolder()
{
	ii $($PSTranscriptDir)
}

function LockedOut()
{
	while (1 -ne 2)
	{
	  $CurrentUser = $env:USERNAME
	  $LockedOut = (Get-ADUser -Properties Lockedout -Filter {SamAccountName -like $CurrentUser}).LockedOut
	  if ($LockedOut -eq $true) 
	  {
		[console]::beep(500,300)
		write-host "$(Get-Date) - $CurrentUser is Locked out" -ForegroundColor Red
	  }
	  else
	  {
		write-host "$(Get-Date) - $CurrentUser is not locked out yet" -ForegroundColor Green
	  }
	  
	  Start-Sleep -Seconds 5 -OutVariable $null
	  Get-PSSession | Remove-PSSession
	}
}

function JMeterOpenGUI ()
{
	start-process "C:\ProgramData\chocolatey\lib\jmeter\tools\apache-jmeter-5.1\bin\jmeter.bat"
}

function DebugSet ()
{
param(
[Parameter(Mandatory=$true,
  HelpMessage="https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-6#debugpreference")]
[ValidateNotNullOrEmpty()]
[ValidateSet("Stop", "Inquire", "Continue", "SilentlyContinue")]
[Alias("B","Whatchugondo")]
[String]
$Behavior
)

$DebugPreference=$Behavior
"Debug Preference set to: {0}." -f $DebugPreference
	
}

#endregion shortcuts

# Final Setup after function definitions
# Determine if the shell is running as admin or not, if admin configure a seperate color scheme

#region Visuals

if (isAdmin)
{
    color admin
    write-host "ADMIN SHELL. " -NoNewline
}
else
{
    color default
}

DebugSet Inquire

#endregion Visuals

#region Windows Services

function CheckService ($ServiceName)
{
	if (Get-Service $ServiceName -ErrorAction SilentlyContinue)
    {
        Write-Host = (Get-Service -Name $ServiceName).Status
    }
    else
    {
        Write-Host "$(ServiceName) not found"
    }
}

function StopService ($Servicename)
{
	if ((Get-Service -Name $ServiceName).Status -eq 'Running')
	{
		Write-Host $ServiceName "is running, preparing to stop..."
		Get-Service -Name $ServiceName | Stop-Service -ErrorAction SilentlyContinue
	}
	elseif ((Get-Service -Name $ServiceName).Status -eq 'Stopped')
	{
		Write-Host $ServiceName "already stopped!"
	}
	else
	{
		Write-Host $ServiceName "-" $ServiceStatus
	}
}

function StartService ($Servicename)
{
	if ((Get-Service -Name $ServiceName).Status -eq 'Running')
	{
		Write-Host $ServiceName "already running!"
	}
	elseif ((Get-Service -Name $ServiceName).Status -eq 'Stopped')
	{
		Write-Host $ServiceName "is stopped, preparing to start..."
		Get-Service -Name $ServiceName | Start-Service -ErrorAction SilentlyContinue
	}
	else
	{
		Write-Host $ServiceName "-" $ServiceStatus
	}
}

#endregion Windows Service


