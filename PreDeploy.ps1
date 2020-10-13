Remove-Variable * -ErrorAction SilentlyContinue
cls
""
Write-Host Instalação do Windows 10 -f Yellow
"--"

Do{
""
$user = Read-Host 'Digite o seu usuário'
$password = Read-Host 'Senha' -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential ("$User", $password)

$admUser = "domain\admin_wds"
$admPassword = "76492d1116743f0423413b16050a5345MgB8AGIAVQBFADAAeQBpAGcAVQBZADcAYwBFAFUAYgBjAGcASQBXAC8AUwBvAHcAPQA9AHwAYwA2ADAANgAwADgAMwBiADEAZABhAGMAYgA0AGMANgBjADIAYwA5ADYAZABjADgAZgAzADgANwBlADkAYQBiAGYANwBlADUAYQA1ADIAMgA2ADYAYwA0ADMAZgA5ADcAMQBjAGEAZABkADAAMgBjAGEAOQA5ADMAMQA1ADYANQA="
$Key = 206,118,190,69,242,187,151,69,115,174,191,206,205,214,225,6,247,25,37,22,223,40,86,144,40,171,156,237,31,1,80,189
$admCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $admUser, ($admPassword | ConvertTo-SecureString -Key $key)

$check = try{(Get-ADGroupMember WDS -Server domain.com.br -Credential $cred).samaccountname}catch{}

if (!$?){
""
Write-Host Erro: Usuário e/ou senha incorreto"(s)". -b Red 
    }
}While($check -eq $null)


if ($check -notcontains $user){
""
Write-Host Você não possui permissão para iniciar esta atividade. Seu usuário precisa ser incluído no grupo """WDS""" do Active Directory. -b Red
""
pause
Restart-Computer -Force -Confirm:$false
read-host
}

Do{
""
$asset = Read-Host 'Número de patrimônio da máquina'
if ($asset -notmatch '^\d{4}$'){
""
Write-Host Formato de patrimônio incorreto. O número de patrimônio precisa conter 4 dígitos -b Red
    }
}While ($asset -notmatch '^\d{4}$')

$local = (ipconfig | Out-String).split("`n") | ? {$_ -like "*ipv4*"}
if ($local -match "10.0"){
$hostname = "RJ"+$asset
}else{
$hostname = "SP"+$asset
}

$account = Get-ADComputer -Server domain.com.br -Filter "name -like '*$asset*'" -Credential $admCred
if ($account -ne $null){$account | % {Remove-ADComputer $_ -Server domain.com.br -Credential $admCred -Confirm:$false}}

(Get-Content w:\autounattend_custom.xml).Replace("host","$hostname") | Out-File w:\autounattend.xml -Encoding utf8

Start-Process w:\setup.exe -ArgumentList "/unattend:w:\autounattend.xml" 

sleep 180

$drive = (get-volume).DriveLetter
foreach ($d in $drive){
$d += ':'
$winPath = dir $d | ? {$_.name -like "*~BT*"}
if ($winPath -ne $null) {
$winPath = $d
break
    }
}

Copy-Item w:\Settings -Recurse -Destination $winPath\Temp -Verbose

cls
""
Write-Host Reiniciando... -f Yellow