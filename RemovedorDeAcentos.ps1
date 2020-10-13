Remove-Variable * -ErrorAction SilentlyContinue
cls
function Remove-Acentos {
param ([String]$src = [String]::Empty)
  $normalized = $src.Normalize( [Text.NormalizationForm]::FormD )
  $sb = new-object Text.StringBuilder
  $normalized.ToCharArray() | ForEach-Object { 
    if( [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($_)
    }
  }
  $sb.ToString()
}

#EXEMPLO
Do {
""
  [array]$name+= Read-Host 'Nome'
  ""
  $continue = Read-Host 'Adicionar mais nomes? (S/N)'

}while ($continue.ToLower() -eq 's')

""
$name | ForEach-Object {Remove-Acentos $_}