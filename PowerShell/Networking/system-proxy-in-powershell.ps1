# import proxy server configurations from Windows settings (Internet Explorer):
netsh winhttp import proxy source=ie

# If you are authorized on your computer under a domain account,
# and your proxy server supports Active Directory Kerberos, or NTLM authentication 
# (if you have not disabled it yet), then you can use the current user credentials to 
# authenticate on the proxy server (you do not need to re-enter your username and password):
$Wcl = new-object System.Net.WebClient
$Wcl.Headers.Add("user-agent", "PowerShell Script")
$Wcl.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

# Test the proxy server
# Return the public IP address of the proxy server
(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content