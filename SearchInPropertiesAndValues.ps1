(Get-AzureADUser -ObjectId $User | fl | Out-String).Split("`n") | ? {$_ -like "*search*"}
