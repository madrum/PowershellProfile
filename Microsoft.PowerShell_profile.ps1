#region Transcript

$PSTranscriptDir = "$env:USERPROFILE\Documents\WindowsPowerShell\transcripts\$(Get-Date -Format yyyy)\$(Get-Date -Format MM)\$(Get-Date -Format dd)"

$TranscriptName = "$(get-date -Format yyyyMMdd-hhmmss).txt"



New-Item -ItemType Directory -Path $PSTranscriptDir -Force | Out-Null

Start-Transcript "$($PSTranscriptDir)\$($TranscriptName)" | Out-Null



Write-Host "Transcript Directory: $($PSTranscriptDir)"

Write-Host "Transcript started: $($TranscriptName)"

#endregion Transcript

#region Tab Completion Behavior

Set-PSReadlineKeyHandler -Chord Tab -Function Complete
Set-PSReadlineKeyHandler -Chord CTRL+Tab -Function TabCompleteNext
Set-PSReadlineOption -ShowToolTips -BellStyle Visual

#endregin Tab Completion Behavior

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
     start-process -FilePath $npp -ArgumentList $file
}

function OpenHostFile()
{
    $hostsPath = "$env:windir\System32\drivers\etc\hosts"
    npp $hostsPath
}

function ViewHostFile()
{
	$hostsPath = "$env:windir\System32\drivers\etc\hosts"
	get-content $hostsPath | write-host
}

#endregion shortcuts

# Final Setup after function definitions
# Determine if the shell is running as admin or not, if admin configure a seperate color scheme

#region Visuals

if (isAdmin)
{
    color admin
    write-host "ADMIN SHELL`n"
}
else
{
    color default
}

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
