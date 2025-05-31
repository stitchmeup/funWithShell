try {
    $i = 0
    While($i -lt 1) {
        Start-Sleep 5 
        $i++
    }
    exit 0
} catch {
    Write-Host "Error: $_"
    exit 1
# The "finally" section of a try/catch/finally block set is still executed when the script terminates because of any of these conditions:
#
#    - Ctrl+C was pressed (at any time)
#    - The Exit keyword was encountered inside the catch section
#    - A fatal error occurred (outside the "finally" section itself)
# https://stackoverflow.com/questions/20708685/handle-keyboard-interrupt-execute-end-block
} finally {
    Write-Host "Finally..."
}