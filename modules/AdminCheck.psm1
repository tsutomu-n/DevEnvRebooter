# AdminCheck.psm1
#
# This module checks if the current user has administrator privileges.

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
    Checks if the current user has administrator privileges.

    .DESCRIPTION
    This function checks if the current user has administrator privileges.
    If not, it shows a warning message.

    .OUTPUTS
    [bool] True if the user has admin privileges, False otherwise
    #>

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "This script must be run with administrator privileges."
        Write-Host "Please run PowerShell as an administrator and try again."
    }
    
    return $isAdmin
}

# Export function
Export-ModuleMember -Function Test-AdminPrivileges
