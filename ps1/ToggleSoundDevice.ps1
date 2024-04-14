<#
Use 
   Get-AudioDevice -List
to learn about available devices on your system.
Then set the two variables below with the start of their names.

https://superuser.com/questions/1054594/switching-default-audio-device-with-a-batch-file

#>
$device1 = "耳机"
$device2 = "扬声器"

$AD = Get-AudioDevice -playback
Write-Output "Audio device was " $AD.Name
Write-Output "Audio device now set to " 

if ($AD.Name.StartsWith($device1)) {
   (Get-AudioDevice -list | Where-Object Name -like ("$device2*") | Set-AudioDevice).Name
}  Else {
   (Get-AudioDevice -list | Where-Object Name -like ("$device1*") | Set-AudioDevice).Name
}