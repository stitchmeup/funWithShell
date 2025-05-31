function Wait-Me {
    Write-Host "Sleeping..."
    Start-Sleep 5
    Write-Host "Waking up..."
    Get-Random -InputObject ([bool]$True,[bool]$False)
}

$sleep = $True

While ($sleep) {
    try {
        Write-Host "Trying to sleep..."
        $sleep = Wait-Me
    } catch {
        Write-Host $_
    } finally {
        Write-Host "Finally..."
        Start-Sleep 2
    }
}