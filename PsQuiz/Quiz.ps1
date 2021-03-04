Remove-Variable * -ErrorAction SilentlyContinue
cls

$AllQuestions = (dir Questions).FullName | Sort-Object {Get-Random}
$QuestionQtd = $AllQuestions.Count

foreach ($QuestionFile in $AllQuestions){
    cls
    ""
    $Question = Get-Content $QuestionFile
    $Answer = $Question -match '^_' -replace '_'
    $Explanation = $Question -match '^~' -replace '~'
    $CurrentQuestion++

    Write-Host [$CurrentQuestion/$QuestionQtd]' ' -NoNewline -f Yellow

    $Question -match '^!' -replace '!'
    $Options = $Question -match '^%' -replace '%'
    [System.Collections.ArrayList]$OptionsQtd = 0..($Options.Length-1)
    [System.Collections.ArrayList]$OptionsObj = @()

    ""
    Do{
        $Num++
        $RandomOption = $OptionsQtd | Get-Random
        $OptionsObj.Add([string]$Num + ': ' + $Options[$RandomOption]) | Out-Null
        $OptionsQtd.Remove($RandomOption)
    }Until ($OptionsQtd.Count -eq 0)

    $OptionsObj
    ""

    $Resposta = Read-Host -Prompt 'Resposta'
    $CheckResposta = $OptionsObj -match "$Resposta\: " -replace "$Resposta\: "
    ""

    if ($Answer -eq $CheckResposta){
        Write-Host Resposta correta! -f Green
        ""
        Write-Host ($Explanation) -Separator "`n" -f Yellow 
        $Correct++
    }else{
        $CorrectAnswer = $OptionsObj | ? {$_ -like "*$answer"}
        Write-Host Resposta errada -f Red
        Write-Host 'Resposta correta: ' -NoNewline
        Write-Host $CorrectAnswer -f Green 
        ""
        Write-Host ($Explanation) -Separator "`n" -f Yellow 
    }

    Remove-Variable Num
    Read-Host

}

cls
""

[int]$Result = (100 * $Correct) / $QuestionQtd

Write-Host Você acertou $Result% das questões -f Yellow
Write-Host Acertou $Correct de $QuestionQtd questões -f Yellow

if ($Result -lt 50){
    Write-Host 'Infelizmente você não foi bem no teste, precisa estudar mais.' -b Red
}elseif($Result -ge 50 -and $Result -le 70){
    Write-Host 'Você está indo bem, continue nesse ritmo para evoluir para uma nota mais alta!' -b DarkYellow
}elseif($Result -gt 70 -and $Result -lt 100){
    Write-Host 'Você atingiu a média e foi aprovado com sucesso, parabéns!' -b DarkGreen
}else{
    Write-Host 'UOOOU, VOCÊ ACERTOU TODAS AS QUESTÕES DO TESTE! ' -NoNewline -b Cyan
    
    function ColoredAsterisks { 
    Write-Host * -b Gray -NoNewline
    Write-Host * -b Magenta -NoNewline
    Write-Host * -b Green -NoNewline
    }

    ColoredAsterisks;Write-Host GODLIKE -b DarkBlue -NoNewline;ColoredAsterisks

    }

Read-Host
