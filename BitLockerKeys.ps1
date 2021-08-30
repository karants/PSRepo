$table = Get-ADComputer -Filter * -Properties name, operatingsystem, 'msTPM-OwnerInformation' | sort name | select name, @{n='RecoveryKey';e={[string]::Join(', ', (Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $_.DistinguishedName -Properties 'msFVE-RecoveryPassword').'msFVE-RecoveryPassword')}} 
$table | ForEach-Object -Process {if ($_.RecoveryKey) { $_}} | epcsv "C:\temp\BitLocker Recovery Keys.csv" -NoTypeInformation


#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
#Variables for Processing
$WebUrl = ""  
$LibraryName ="Documents"
$SubFolderName = "General"
$SourceFile="C:\temp\BitLocker Recovery Keys.csv" 
$AdminName =""  
$PasswordFile = "C:\servicepwd.txt"
  
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminName,(Get-content $PasswordFile | ConvertTo-SecureString))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebUrl)
$Context.Credentials = $Credentials
 
#Get the Library
$Library =  $Context.Web.Lists.GetByTitle($LibraryName)
$FolderToBindTo = $Library.RootFolder.Folders
$Context.Load($FolderToBindTo)
$Context.ExecuteQuery()
$FolderToUpload = $FolderToBindTo | Where {$_.Name -eq $SubFolderName}

#Get the file from disk
$FileStream = ([System.IO.FileInfo] (Get-Item $SourceFile)).OpenRead()
#Get File Name from source file path
$SourceFileName = Split-path $SourceFile -leaf
   
#sharepoint online upload file powershell
$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
$FileCreationInfo.Overwrite = $true
$FileCreationInfo.ContentStream = $FileStream
$FileCreationInfo.URL = $SourceFileName
$FileUploaded = $FolderToUpload.Files.Add($FileCreationInfo)
#$FileUploaded
#powershell upload single file to sharepoint online
$Context.Load($FileUploaded)
$Context.ExecuteQuery()
 
#Close file stream
$FileStream.Close()
  
write-host "File has been uploaded!"

