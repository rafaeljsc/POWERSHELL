cls
$jobs = @()

$urls = 'facebook.com','google.com','youtube.com','outlook.com'
foreach ($url in $urls){
    $jobs += Start-Job -Name Ping {param($url) Test-Connection $url} -ArgumentList $url
}

foreach ($job in $jobs){
    Receive-Job $job -AutoRemoveJob -Wait
}