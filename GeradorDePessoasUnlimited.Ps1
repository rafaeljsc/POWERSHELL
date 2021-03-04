Remove-Variable * -ErrorAction SilentlyContinue
cls

[System.Collections.ArrayList]$TotalPessoas = @()
[int]$MaxPessoas = Read-Host 'Num de pessoas você precisa'
""
Write-Host Gerando pessoas. Aguarde... -f Yellow

$ie = new-object -com "InternetExplorer.Application"
$ie.visible = $false
$ie.navigate("https://www.4devs.com.br/gerador_de_pessoas")
while($ie.Busy){sleep 3}

while(!$Done){
    if ($MaxPessoas -gt 30){
            $MaxPessoas -= 30
            $Value = 30
        }else{
            $Value = $MaxPessoas
            $Done++
        }

    ($ie.Document.getElementById('txt_qtde')).value = $Value
    ($ie.Document.getElementById('bt_gerar_pessoa')).click()

    Do{
    $pessoas = $ie.Document.getElementById('dados_json') | ? {$_.InnerHTML -notlike '*Aguarde*'}
    sleep 2
    }While(!$pessoas)

    $pessoas = ($ie.Document.getElementById('dados_json')).InnerHTML | ConvertFrom-Json
    $TotalPessoas.add($pessoas) | Out-Null
}

$ie.quit()

""
Write-Host 1: .txt
Write-Host 2: .csv
Write-Host 3: .json
""
Write-Host 'Saída: ' -NoNewline -f Yellow; $Output = Read-Host 

if ($Output -eq 1){
    $FormatEnumerationLimit=-1
    $Outfile = 'Pessoas.txt'
    $TotalPessoas | ft * -AutoSize | Out-File $Outfile -Width 999999999 -Force

}elseif ($Output -eq 2){
    $Outfile = 'Pessoas.csv'
    ($TotalPessoas | ConvertTo-Json | ConvertFrom-Json).value | ConvertTo-Csv -NoTypeInformation | Set-Content $Outfile

}else{
    $Outfile = 'Pessoas.json'
    $TotalPessoas | ConvertTo-Json | Out-File $Outfile
    }

""
Write-Host Dados salvos em $PSScriptRoot\$Outfile -f Green