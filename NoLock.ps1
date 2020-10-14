[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
while ($true)
{
  [System.Windows.Forms.SendKeys]::SendWait("{CAPSLOCK 2}")
  sleep 60
}
