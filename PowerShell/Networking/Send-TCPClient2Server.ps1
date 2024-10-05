# Send-TCPClient2Server.ps1
# Send Raw Data Bytes through TCP Socket
# Client -> Server
# 1. Receive
# 2. Send
# 3. Close
param(
  [String] $Path,
  [String] $RemoteHost,
  [String] $RemotePort
)

$Server = if ( [bool] $RemoteHost ) { $RemoteHost } else { "127.0.0.1" }
$Port = if ( [bool] $RemotePort ) { $RemotePort } else { "4444" }

try {
  $tcpConnection = New-Object System.Net.Sockets.TcpClient($Server, $Port)

  Write-Host "Establishing connection..."
  $tcpStream = $tcpConnection.GetStream()
  Write-Host "Connextion Established"

  Write-Host "Setting streams..."
  $reader = New-Object System.IO.StreamReader($tcpStream)
  $writer = New-Object System.IO.StreamWriter($tcpStream)
  $writer.AutoFlush = $true
  Write-Host "Streams Set!"

  Write-Host "Loading payload to send..."
  [System.Object[]] $fileContent = Get-Content -Path $Path
  Write-Host "Payload loaded..."

  $buffer = New-Object System.Byte[] 1024
  $encoding = New-Object System.Text.ASCIIEncoding

  if ( $tcpConnection.Connected ) {
    while ( $tcpConnection.DataAvailable ) {
      Write-Host "Reading Data..."
      $rawResponse = $reader.Read($buffer, 0, 1024)
      $response = $encoding.GetString($buffer, 0, $rawResponse)
      Write-Host $response
      Write-Host "Data Read!"
    }

    if ( $tcpConnection.Connected ) {
      Write-Host "Sending payload..."
      Foreach ( $line in $fileContent ) {
        $writer.WriteLine($line) | Out-Null
      }
      Write-Host "Payload Sent!"
    }
  }
  if ( $tcpConnection.Connected ) {
    Write-Host "Closing streams and socket properly..."
    $reader.Close()
    $writer.Close()
    $tcpConnection.Close()
    Write-Host "Closed!"
  }
} catch {
  Write-Error ("FAILURE: {0}" -f $_)
}
