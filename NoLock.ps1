mode 40,10
Write-Host NoLock ativado! -b Green
""
Write-Host Feche esta janela para desativar -f Yellow.
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
while (!$loop)
{
  [System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK 2}")
  sleep 60
}
