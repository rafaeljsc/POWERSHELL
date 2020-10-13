Remove-Variable * -ErrorAction SilentlyContinue

$capsImg = {Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$img = [System.Drawing.Image]::Fromfile($png)
$CapsLock                   = New-Object system.Windows.Forms.Form
$CapsLock.Width             = $img.Width
$CapsLock.Height            = $img.Height
$CapsLock.TopMost           = $true
$CapsLock.BackgroundImage   = $img
$CapsLock.AllowTransparency = $true
$CapsLock.TransparencyKey   = $CapsLock.BackColor
$CapsLock.StartPosition     = 1
$CapsLock.FormBorderStyle   = 0
$CapsLock.ShowInTaskbar     = 0
$CapsLock.Show()

Start-Sleep -Seconds 1
$CapsLock.Close()
}

$Caps = New-Object -ComObject "Word.Application"

Do{
if ($Caps.CapsLock){
$png = 'img\capson.png'
&$capsImg
While ($Caps.CapsLock){sleep 0.1}
}else{
$png = 'img\capsoff.png'
&$capsImg
While (!$Caps.CapsLock){sleep 0.1}
    }
}While($loop -eq $null)