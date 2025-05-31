function Write-Log {
    param(
        [Parameter(Mandatory=$True)]
        [string]$message,
        [Parameter(Mandatory=$True)]
        [string]$log_file_path
    )
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $log_message = "{0} - {1}" -f $date, $message
    Write-Host $log_message
    try {
    Add-Content -Path $log_file_path -Value $log_message
    } catch [ArgumentException] {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
