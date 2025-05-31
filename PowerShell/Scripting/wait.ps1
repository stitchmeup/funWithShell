function Wait-Me {
    Write-Host "Sleeping..."
    Start-Sleep 120
    Write-Host "Waking up..."
    Get-Random -InputObject ([bool]$True,[bool]$False)
}


function Start-WaitMeJob {
    $sleep = $True

    While ($sleep) {
        try {
            Write-Host "Trying to sleep..."
            $sleep = Wait-Me
        } catch {
            Write-Host $_
        } finally {
            Write-Host "Finally..."
            Start-Sleep 5
        }
    }
}

try {
    Start-Job -Name "WaitMe" -ScriptBlock ${function:Start-WaitMeJob}
    Get-Job -Name "WaitMe" | Wait-Job -Timeout 30
    If (Get-Job -Name "WaitMe" | Where-Object {$_.State -eq "Running"}) {
        Write-Host "WaitMe is still running..."
        Get-Job -Name "WaitMe" | Stop-Job
        Write-Host "WaitMe has been stopped..."
    }
} catch {
    Write-Host $_
} finally {
    Write-Host "Finally..."
    Get-Job | Remove-Job
}