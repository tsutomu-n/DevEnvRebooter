# AdminCheck.psm1
#
# This module checks if the current user has administrative privileges.

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
    Checks if the current user has administrative privileges.

    .DESCRIPTION
    This function checks if the current user has administrative privileges.
    If not, it displays a warning message.

    .OUTPUTS
    [bool] True if the user has administrative privileges, otherwise False.
    #>

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "This script must be run with administrator privileges."
        Write-Host "Please run PowerShell as an administrator and try again."
    }
    
    return $isAdmin
}

function Restart-ScriptAsAdmin {
    <#
    .SYNOPSIS
    Restarts the script with administrative privileges.

    .DESCRIPTION
    This function restarts the script with administrative privileges.

    .OUTPUTS
    None
    #>
    
    if (-not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "powershell"
        $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
        $newProcess.Verb = "runas"
        [System.Diagnostics.Process]::Start($newProcess) | Out-Null
        Exit
    }
}

# Export functions
Export-ModuleMember -Function Test-AdminPrivileges, Restart-ScriptAsAdmin
