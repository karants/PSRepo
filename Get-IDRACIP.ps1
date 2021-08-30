$computers = ;
$list = @();
$list += Invoke-Command -ComputerName $computers -ScriptBlock { $var = racadm getniccfg; $ipadd = $var[5].remove(0,23); $idracinfo =  $env:COMPUTERNAME + "  =  " + $ipadd; $idracinfo }
Write-Output $list
