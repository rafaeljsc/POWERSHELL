Remove-Variable * -ErrorAction SilentlyContinue
Write-Host Verificando Nuget -f Yellow
$NugetPackage = Get-PackageProvider | ? {$_.Name -eq "NuGet"}
if(!$NugetPackage){
""
Write-Host Instalando Nuget -f Yellow
$NugetInstall = Install-PackageProvider -Name nuget -Scope CurrentUser -Force -Confirm:$false
if(!$?){
""
Write-Host Não foi possível instalar o Package -b Red
""
pause
    }
}

""
Write-Host Verificando módulo MSOnline -f Yellow

$MSOnline = Get-InstalledModule -Name MSOnline
if (!$MSOnline){
$MSOnline = Install-Module MSOnline -Scope CurrentUser -Force -Confirm:$false
if (!$?){
Write-Host Não foi possível instalar o módulo -b Red
""
pause
    }
}

""
Write-Host Verificando módulo Azure -f Yellow

$AzureAD = Get-InstalledModule -Name AzureAD
if (!$AzureAD){
$AzureAD = Install-Module AzureAD -Scope CurrentUser -Force -Confirm:$false
if (!$?){
Write-Host Não foi possível instalar o módulo -b Red
""
pause
    }
}

$Excel = Get-InstalledModule | ? {$_.name -eq 'importexcel'}
if (!$Excel){
Install-Module importexcel -Scope CurrentUser -Confirm:$false -Force
if(!$?){
""
Write-Host Não foi possível instalar o Package -b Red
""
pause
    }
}


""
Write-Host Conectando ao servidor -f Yellow
""
Write-Host 'E-mail: ' -f Yellow -NoNewline
$365User = Read-Host

$365Password = Read-Host -Prompt 'Password' -AsSecureString
$365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $365User, $365Password
Connect-MsolService -Credential $365Cred | Out-Null
Connect-AzureAD -Credential $365Cred | Out-Null

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $365Cred -Authentication Basic -AllowRedirection
Import-PSSession -Session $Session -AllowClobber | Out-Null