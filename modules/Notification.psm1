# Notification.psm1
#
# This module handles user notifications.

function Show-Notification {
    <#
    .SYNOPSIS
    Shows a notification using the specified method.

    .DESCRIPTION
    This function shows a notification using the specified method
    (console, popup, or toast).

    .PARAMETER message
    The notification message.

    .PARAMETER title
    The notification title (default: "Notification").

    .PARAMETER method
    The notification method ("console", "popup", "toast").

    .OUTPUTS
    None
    #>

    param (
        [string]$message,
        [string]$title = "Notification",
        [string]$method = "console" # "console", "popup", "toast"
    )
    
    switch ($method) {
        "console" {
            Write-Host $message -ForegroundColor Green
        }
        "popup" {
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show($message, $title)
        }
        "toast" {
            New-BurntToastNotification -Text $title, $message
        }
    }
}

function Show-ErrorNotification {
    <#
    .SYNOPSIS
    Shows an error notification.

    .DESCRIPTION
    This function shows an error message in a popup.

    .PARAMETER message
    The error message.

    .PARAMETER title
    The error title.

    .OUTPUTS
    None
    #>

    param (
        [string]$message,
        [string]$title
    )
    
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, $title, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
}

# Export functions
Export-ModuleMember -Function Show-Notification, Show-ErrorNotification
