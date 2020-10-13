cls
Remove-Variable * -ErrorAction SilentlyContinue

$CheckModule = Get-Module ImportExcel
if ($CheckModule -eq $null){

""
Write-Host Instalando módulo para Excel. Aguarde... -f Yellow
Install-Module -Name ImportExcel -Confirm:$false -Force
}

""
"Movimentações para Active Directory"
"--"

""
Write-Host Colunas suportadas pelo script: -f Yellow

""
Write-Host •Login -f Yellow
Write-Host •Cargo -f Yellow
Write-Host •Login_Gestor -f Yellow
Write-Host •Departamento -f Yellow

""
Write-Host *** VERIFIQUE O PREENCHIMENTO DAS LINHAS NESSAS COLUNAS ANTES DE PROSSEGUIR *** -f Yellow

Do{
""
$sheet = Read-Host -Prompt 'Digite o caminho da planilha'
$CheckFile = Test-Path $sheet
if ($CheckFile -eq $false){
""
Write-Host Não foi possível encontrar o arquivo """$sheet""". -f Yellow
    }
}While ($CheckFile -eq $false)

"" 
Write-Host Atualizando objetos. Aguarde... -f Yellow

""
$sheet = Import-Excel $sheet

foreach ($s in $sheet){
$login = ($s.login).trim()
try{Get-ADUser $login | Out-Null -ErrorAction SilentlyContinue}catch{}

if ($? -eq $false){
$ErrorUsers+= "`n$Login"
}else{

$cargo = ($s.cargo).trim()
$gerente = ($s.login_gestor).trim()
$gerente = (Get-ADUser $gerente).DistinguishedName
$departamento = ($s.departamento).trim()

if ($cargo){Set-ADUser $login -Title "$Cargo" -Confirm:$false}
if ($departamento){Set-ADUser $login -Department "$departamento" -Confirm:$false}
if ($gerente){Set-ADUser $login -Manager "$gerente" -Confirm:$false}

$DC = "DC1","DC2","DC3"

foreach ($Server in $DC) {
Get-ADUser $login | Sync-ADObject -Destination $Server}
Write-Host $Login atualizado! -ForegroundColor Green
        }
    }
}

if ($ErrorUsers){

"Não foi possível analisar os seguintes usuários: "
""
Write-Host $ErrorUsers -ForegroundColor Red 

}else{
""
"--"
Write-Host SUCESSO! -f Green
}