$assets = Get-Content -Path C:\Users\kshah\Documents\assets.txt

foreach ($asset in $assets)
{

if(Test-Connection -ComputerName $asset -Count 1 -ErrorAction SilentlyContinue){
    (Get-WmiObject -ComputerName $asset -Query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    }
}