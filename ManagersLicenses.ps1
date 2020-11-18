Remove-Variable * -ErrorAction SilentlyContinue
cls
""
Write-Host Gerenciador de licenças por gestores -f Cyan
"---"

""
.\365Connector.ps1

""
Write-Host Recebendo gestores -f Yellow

$Managers = Get-ADUser -Filter * -Properties DirectReports | ? {$_.DirectReports}

""
Write-Host Recebendo usuários licenciados no O365 -f Yellow
$UsersLicensed = Get-MsolUser -All | ? {$_.isLicensed} | Select UserPrincipalName,Licenses

""
Write-Host Recebendo gerenciados -f Yellow

$Csv = foreach ($Manager in $Managers){
$UsersManaged = $Manager.DirectReports | % {try{(Get-ADObject $_ -Properties UserPrincipalName).UserPrincipalName}catch{}}

$msg1++ ;if ($msg1 -eq 1){
""
Write-Host Filtrando licenças -f Yellow}
$UsersManaged = $UsersLicensed | ? {$UsersManaged -contains $_.UserPrincipalname}

if ($UsersManaged){
Remove-Variable E1,E3,F3 -ErrorAction SilentlyContinue
$UsersManaged | % {
if ($_.Licenses.AccountSkuId -match "STANDARDPACK"){$E1++}
if ($_.Licenses.AccountSkuId -match "ENTERPRISEPACK"){$E3++}
if ($_.Licenses.AccountSkuId -match "SPE_F1"){$F3++}
}

[pscustomobject]@{
        'Gestor' = $Manager.name
        'Email' = $Manager.UserPrincipalName
        'E1' = $E1
        'E3' = $E3
        'F3' = $F3
        'Total' = $E1+$E3+$F3
        }
    }
}

$Date = Get-Date -Format _dd.MM.yy_HH.mm
$File = 'ManagerLicenses'
$Output = $File + $Date + '.xlsx'    
$Csv | Export-Excel $Output -NoNumberConversion * -AutoSize -FreezeTopRow