Remove-Variable * -ErrorAction SilentlyContinue
cls

$User = Read-Host 'Usuário'
$UserPassword = Read-Host 'Senha' -AsSecureString
$Cred = New-Object System.Management.Automation.PSCredential ("$User", $UserPassword)

$Output = "$env:LOCALAPPDATA\Temp\Cred.txt"

$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Password = $UserPassword | ConvertFrom-SecureString -key $Key
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($Password | ConvertTo-SecureString -Key $key)

$Key = [string]$key -replace ' ',','

$Credential = @(
'$User = ' + """$User"""
'$Password = ' + """$Password"""
'$Key = ' + $Key
'$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($Password | ConvertTo-SecureString -Key $key)')

$Credential | Out-File $Output | notepad $Output