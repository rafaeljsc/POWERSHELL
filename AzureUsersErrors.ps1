cls
$ProgressPreference = 'SilentlyContinue'

.\365Connector.ps1

""
Write-Host Recebendo usuários -f yellow
$AllUsers = Get-AzureADUser -All:$true

""
Write-Host Filtrando usuários com erros -f yellow
$UsersWithErrors = $AllUsers | ? {$_.ProvisioningErrors}

$Csv = $UsersWithErrors | % {
Remove-Variable Errors -ErrorAction SilentlyContinue
$UsersErrors = $_.ProvisioningErrors.ErrorDetail
$UsersErrors = ([xml]($UsersErrors)).ServiceInstance.ObjectErrors.ErrorRecord | Group ErrorDescription
$UsersErrors | % {
$Errors += "`n`n" + $_.Name
$Errors = $Errors.Trim()
    }

    [pscustomobject]@{
        'Usuário' = ($_.UserPrincipalName).tolower()
        'Erro(s)' = $Errors
        }
}

$Date = Get-Date -Format _dd.MM.yy_HH.mm
$File = 'AzureUsersErrors'
$Output = $File + $Date + '.xlsx'    
$Csv | Export-Excel $Output -NoNumberConversion * -AutoSize