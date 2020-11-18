cls

""
Write-Host Gerenciador de atividade de conta de e-mail -b Black
""
.\365Connector.ps1

""
Write-Host Recebendo usuários licenciados no O365 -f Yellow
$Licenses = "STANDARDPACK","ENTERPRISEPACK","SPE_F1"
$UsersLicensed = Get-MsolUser -All | ? {$_.Licenses.AccountSkuId -match $Licenses[0] -or $_.Licenses.AccountSkuId -match $Licenses[1] -or $_.Licenses.AccountSkuId -match $Licenses[2]}

""
Write-Host Filtrando usuários away -f Yellow
Remove-Variable Count -ErrorAction SilentlyContinue
$Today = Get-Date
$AwayUsers = $UsersLicensed | ? {!$_.LastPasswordChangeTimestamp -or ($Today - $_.LastPasswordChangeTimestamp).days -gt 90}
$AwayUsersLen = $AwayUsers.length
""
Write-Host Compilando... -f Yellow
Sleep 10
$Output = foreach ($User in $AwayUsers){
if (!$User.LastPasswordChangeTimestamp){$LastLogon = 'Nunca utilizou e-mail'}else{$LastLogon = Get-Date $User.LastPasswordChangeTimestamp -Format dd/MM/yyyy}
$DaysAway = ($Today - $User.LastPasswordChangeTimestamp).Days - 90
$License = $User.Licenses.AccountSkuId | ? {$_ -match $Licenses[0] -or $_ -match $Licenses[1] -or $_ -match $Licenses[2]}

[pscustomobject]@{
        'Usuário' = ($User.UserPrincipalName).ToLower()
        'Último Logon' = $LastLogon
        'Licença' = $License.Split(":")[1]
        'Inativo a (dias)' = $DaysAway
        } 
$Count++
Write-Host Usuários processados: $Count/$AwayUsersLen -f Yellow
    }

$Date = Get-Date -Format _dd.MM.yy_HH.mm
$File = 'AwayUsersLicensed'
$FullName = $File + $Date + '.xlsx'    
$Output | Export-Excel $FullName -NoNumberConversion * -FreezeTopRow -AutoSize