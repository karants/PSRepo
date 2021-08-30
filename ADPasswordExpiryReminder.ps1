$ExpireDays = 7
$SendingEmail = "zbc@xyz"
$SMTPHost="smtp.office365.com"
$SMTPUsername="abx@xyz"
$SMTPPassword=Get-Content "C:\Tasks\Scripts\SMTP_Password.txt" | ConvertTo-SecureString
$SMTPCredentials=new-object -typename System.Management.Automation.PSCredential -argumentlist 
$SMTPUsername, $SMTPPassword
Import-Module ActiveDirectory
$AllUsers = get-aduser -filter * -properties * |where {$_.Enabled -eq "True"} |where {$_.PasswordNeverExpires -eq $false} |where {$_.passwordexpired -eq $false}
foreach ($User in $AllUsers)
{
$Name = (Get-ADUser $User | foreach {$_.Name})
$Email = $User.emailaddress
$PasswdSetDate = (get-aduser $User -properties * | foreach {$_.PasswordLastSet })
$MaxPasswdAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
$ExpireDate = $PasswdSetDate + $MaxPasswdAge
$Today = (get-date)
$DaysToExpire = (New-TimeSpan -Start $Today -End $ExpireDate).Days
$EmailSubject="Password Expiry Notice - your password expires in $DaystoExpire days"
$Message="
Dear $Name,
<p> Your Windows password expires in $DaysToExpire days.<br />
If you do not update your password in $DaysToExpire days, you will not be able to log in. <br />
<br />
Sincerely, <br />
IT Department. <br />
</p>"
if ($DaysToExpire -lt $ExpireDays)
{
echo "$Email expires in $DaysToExpire days"
Send-Mailmessage -smtpServer $SMTPHost -Credential $SMTPCredentials -UseSsl -Port 587 -from $SendingEmail -to $Email -subject $EmailSubject -body $Message -bodyasHTML -priority High
} 
}
