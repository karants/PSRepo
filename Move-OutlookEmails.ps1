$ol = New-Object -comobject outlook.application
$ns = $ol.GetNamespace('MAPI')
$store = $ns.Stores['kshah@xyz.com']
$inbox = $store.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)
$root = $store.GetRootFolder()
$primFolder = $root.Folders['Inbox']

#$inbox.Items | 
#	Where-Object{$_.SentOn -ge [datetime]::Today.AddDays(-10)} |
#	ForEach-Object{$_.Move($targetFolder)}

$inboxarray = New-Object System.Collections.ArrayList

$inboxarray = $inbox.Items

for($i=1;$i -le $inboxarray.count;$i++)
{ if($inboxarray[$i].SentOn.Year -eq 2019)
          {
            $targetFolder = $inbox.Folders | where-object {$_.name -eq "_Old Email_2017"}
            $inboxarray[$i].Move($targetFolder) 
          }
}