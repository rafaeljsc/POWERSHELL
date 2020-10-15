Write-Host NoLock ativado! -b Green
""
Write-Host Feche esta janela para desativar -f Yellow.
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
while ($true)
{
  [System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK 2}")
  sleep 60
}
