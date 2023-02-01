Remove-Item Alias:\curl -ErrorAction SilentlyContinue
Clear-Host

#PARAMETROS COMUNS DE REQUEST
$apikey = "8fe92bdcd33bbfa61fe2da001434c1908972497bc7213e8c2c3b86cce6fbbed2"
$file = "C:\Temp\File.exe"
$output = "C:\Temp"

#ENVIA ARQUIVO PARA O VIRUSTOTAL
Write-Host "Enviando arquivo..." 
$apikeyPost = "'apikey=$apikey'"
$file = "'file=@$file'"
$urlPost = "'https://www.virustotal.com/vtapi/v2/file/scan'" 
$responsePost = Invoke-Expression "curl --silent --request POST --url $urlPost --form $apikeyPost --form $file" | Out-String | ConvertFrom-Json

#RECUPERA SCAN DO ARQUIVO NO VIRUSTOTAL
Write-Host "Scaneando..."
$urlGet = "--url https://www.virustotal.com/vtapi/v2/file/report?apikey=$apikey""&""resource=$($responsePost.md5)"
do{
    $responseGet = Invoke-Expression "curl --silent --request GET --url $urlGet" | Out-String | ConvertFrom-Json
    $responseGet.verbose_msg
    Start-Sleep 5
}while (!$responseGet.scans)

#ANALISA O RESULTADO
if ($responseGet.positives -gt 0){
    $detections = @()
    $avs = ($responseGet.scans | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}).Name
    foreach ($av in $avs){
        $scan = $responseGet.scans | Select-Object -ExpandProperty $av | Select-Object detected,result
        if ($scan.detected){
            $detections += New-Object -TypeName psobject -Property @{av=$av; threat=$scan.result; threatCount=""}          
        }
    }
    Write-Host "$($responseGet.positives) ameaças encontradas:"
    ""
    $detections[-1].threatCount = $responseGet.positives
    $detections | Select-Object av,threat,threatCount
    $detections | Select-Object av,threat,threatCount | Export-Csv -Encoding UTF8 -NoTypeInformation -Path "$output\detections.csv" -Force
}

#AÇÃO A SER EXECUTADA CASO UMA AMEAÇA SEJA ENCONTRADA
if ($detections){

}else{
    Write-Host "Nenhuma ameaça encontrada"
}