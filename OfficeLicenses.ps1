cls
Remove-Variable * -ErrorAction SilentlyContinue
$ProgressPreference = 'SilentlyContinue'

.\365Connector.ps1

""
Write-Host Obtendo preços das licenças no site da Microsoft -f Yellow

$E1Link = "https://www.microsoft.com/pt-br/microsoft-365/enterprise/office-365-e1"
$E3Link = "https://www.microsoft.com/pt-br/microsoft-365/enterprise/office-365-e3"
$F3Link = "https://www.microsoft.com/pt-br/microsoft-365/enterprise/office-365-f3"
$ie = new-object -ComObject "InternetExplorer.Application"

$ie.navigate($E1Link)
while($ie.Busy) { Sleep 3 }
[string]$E1Price = ($ie.Document.getElementsByTagName("span") | ? {$_.InnerHTML -like '*R$*'}).InnerHTML.replace(',','.')
$E1Price = $E1Price.Split() | ? {$_ -match '\d'}
[float]$E1Price = $E1Price

$ie.navigate($E3Link)
while($ie.Busy) { Sleep 3 }
[string]$E3Price = ($ie.Document.getElementsByTagName("span") | ? {$_.InnerHTML -like '*R$*'}).InnerHTML.replace(',','.')
$E3Price = $E3Price.Split() | ? {$_ -match '\d'}
[float]$E3Price = $E3Price

$ie.navigate($F3Link)
while($ie.Busy) { Sleep 3 }
[string]$F3Price = ($ie.Document.getElementsByTagName("span") | ? {$_.InnerHTML -like '*R$*'}).InnerHTML.replace(',','.') 
$F3Price = $F3Price.Split() | ? {$_ -match '\d'}
[float]$F3Price = $F3Price


""
Write-Host Verificando licenças -f Yellow
$Licenses = Get-MsolAccountSku | ? {$_.SkuPartNumber -eq "STANDARDPACK" -or $_.SkuPartNumber -eq "ENTERPRISEPACK" -or $_.SkuPartNumber -eq "SPE_F1"}
$IdLicenses = $Licenses.AccountSkuId

$Output = $Licenses | % {
$License = $IdLicenses -match $_.AccountSkuId

if ($License -like "*STANDARD*"){
$LicenseName = 'E1'
$Price = $E1Price
}

if ($License -like "*ENTERPRISEPACK*"){
$LicenseName = 'E3'
$Price = $E3Price
}

if ($License -like "*SPE_F1*"){
$LicenseName = 'F3'
$Price = $F3Price
}

$Total = $_.ActiveUnits
$Available = $_.ActiveUnits - $_.ConsumedUnits; if ($Available -lt 0){$Available = 0}
$TotalPartial += ($Total * $Price)
$CheckLicenseLength = $Licenses.Length - 1 - $Licenses.AccountSkuId.IndexOf($_.AccountSkuId)
if ($CheckLicenseLength -eq 0){$TotalCost = $TotalPartial.ToString('C',[cultureinfo]'pt-br')}
$Cost = ($Total * $Price).ToString('C',[cultureinfo]'pt-br') 

[pscustomobject]@{
        'Licença' = $LicenseName
        'Total' = $Total
        'Disponíveis' = $Available
        'Custo/Mês' = $Cost
        'Total/Mês' = $TotalCost
        
            }
}

$Date = Get-Date -Format _dd.MM.yy_HH.mm
$File = 'Licenses'
$FullName = $File + $Date + '.xlsx'    
$Output | Export-Excel $FullName -NoNumberConversion * -FreezeTopRow -AutoSize