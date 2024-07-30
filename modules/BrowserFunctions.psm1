# BrowserFunctions.psm1
#
# This module contains functions to manage browsers.

# Import common functions
. "$PSScriptRoot\CommonFunctions.psm1"

function Restart-Browser {
    <#
    .SYNOPSIS
    Restarts the specified browser.

    .DESCRIPTION
    This function stops and restarts the browser specified by the given path.

    .PARAMETER Path
    The path to the browser executable.

    .OUTPUTS
    None
    #>

    param ([string]$Path)
    
    Stop-Applications -Paths @($Path) -Type "Browser"
    Start-Applications -Paths @($Path) -Type "Browser"
}

# Export function
Export-ModuleMember -Function Restart-Browser
