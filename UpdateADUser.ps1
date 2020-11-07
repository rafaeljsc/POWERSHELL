$User = "administrator"
$Password = "413b16050a5345MgB8AGUATQB2AEQARABLAG4AeQBvAEYAaABFAGQANABwAGkASQBnAMgB4AHcAPQA9AHwAYcANQA4AGIAZABjADYAMAA0AGMAZgBkAGQANwBjADYAMQA1ADcAZABmADkANQBiADYANAA2ADgAZABjADcAOABhAGQANABkAGQANgBmADQAMwA0ADAANgBiAGUANgBlAGUAYQBjAGMANgA5ADYAYgA3AGIAYgA4ADIAYQA="
$Key = 232,150,219,143,199,2,221,49,171,159,215,200,234,176,55,53,153,193,23,59,119,65,254,121,219,96,131,219,198,168,158,147
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($Password | ConvertTo-SecureString -Key $key)
$Server = New-PSSession 192.168.0.200 -Credential $Cred
Import-PSSession $Server -Module activedirectory -AllowClobber

$Maite = Get-ADUser maite.fogaca -Properties DirectReports,Title,Manager
$Maite_Staff = $Maite.DirectReports | % {(Get-ADObject $_ -Properties samaccountname)}

$Nina = Get-ADUser nina.santos -Properties DirectReports,Title,Manager
$Nina_Staff = $Nina.directreports | % {(Get-ADObject $_ -Properties samaccountname)}

$Milena = Get-ADUser milena.carvalho

foreach ($User in $Maite_Staff){Set-ADUser $User.SamAccountName -Manager $Nina.DistinguishedName -Confirm:$false}
foreach ($User in $Nina_Staff){Set-ADUser $User.SamAccountName -Manager $Milena.DistinguishedName -Confirm:$false}

Set-ADUser $Nina.SamAccountName -Title $Maite.Title
Set-ADUser $Nina.SamAccountName -Manager $Maite.Manager

Set-ADUser $Milena.SamAccountName -Title $Nina.Title
Set-ADUser $Milena.SamAccountName -Manager $Nina.Manager

Remove-ADUser $maite.SamAccountName -Confirm:$false