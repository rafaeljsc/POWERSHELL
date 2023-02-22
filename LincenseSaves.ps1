Clear-Host
#LICENÇAS
$e5 = 'M365x51807507:ENTERPRISEPREMIUM'
$e3 = 'M365x51807507:ENTERPRISEPACK'

#IMPORTA USUÁRIO DO M365
Write-Host "Importando usuários..."
$users = Get-MsolUser -All | ? {$_.Licenses}

#FILTRA GESTORES
Write-Host "Filtrando gestores..."
$managers = @()
foreach ($user in $users){
    $managers += (Get-AzureADUserManager -ObjectId $user.UserPrincipalName).UserPrincipalName
}
$managers = ($managers | Group-Object).Name
$noManagers = ($users | ? {$_.UserPrincipalName -notin $managers}).UserPrincipalName

#REMOVE AS LICENÇAS DOS USUÁRIOS
Write-Host "Desvinculando licenças..."
foreach ($user in $users){
    $skuIds = $user.Licenses.AccountSkuId
    foreach ($skuId in $skuIds){
        Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $skuId
    }
}

#GERENCIA AS LICENÇAS
$count = 0
foreach ($user in $managers){
    Set-MsolUserLicense -UserPrincipalName $user -AddLicenses $e5
    $count++
    Write-Host "$count/$($users.count) usuários atualizados"
}

foreach ($user in $noManagers){
    Set-MsolUserLicense -UserPrincipalName $user -AddLicenses $e3
    $count++
    Write-Host "$count/$($users.count) usuários atualizados"
}

<#
$before = Get-MsolAccountSku | ? {$_.AccountSkuId -eq $e3 -or $_.AccountSkuId -eq $e5}
$after = Get-MsolAccountSku | ? {$_.AccountSkuId -eq $e3 -or $_.AccountSkuId -eq $e5}
#>