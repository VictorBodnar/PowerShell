$reiteration="y"

While($reiteration="y") {
$a = Read-Host -Prompt "Commands:
`n1. Get timezone data
`n2. Get startup commands data
`n3. Test Internet connection
`n4. Retrieve services
`n5. Retrieve processes
`n6. Get shares
`n7. Get local group memberships
`n8. Get system specifications
`n9. Get disk space allocation
`n10. Get installed programs
`n11. Get NTFS permissions  (WARNING: the cmdlet is not installed by default)
`n12. Get USER ActiveDirectory details
`n13. Get groups a user belongs to
`n14. Get GROUP ActiveDirectory details
`n15. Get Effective Access
`n16. EXIT
`nPlease select a command"
Clear-Host
Switch ($a) {
    1{gwmi win32_timezone -Co (Read-Host "Please input the computer name") | Select * | Out-GridView }
    2{gwmi win32_startupcommand -Co (Read-Host "Please input the computer name") | select *  | Out-GridView}
    3{$result = Test-Connection -Com www.google.com -Quiet
      Write-Host "Internet connection: $result"}
    4{gsv -Co (Read-Host "Please input the computer name") | Select * | Out-GridView}
    5{Get-Process -ComputerName (Read-Host "Please input the computer name") | Select * | Out-GridView}
    6{gwmi Win32_Share -Co (Read-Host "Please input the computer name")  | Out-GridView}
    7{gwmi cm_localgroupmembers -Co (Read-Host "Please input the computer name") | Select Name,Type,Domain,Account | Out-GridView}
    8{gwmi win32_bios -Computername ($x = Read-Host "Please input the computer name")
      gwmi Win32_computerSystem -Co $x | Select Manufacturer
      gwmi Win32_ComputerSystem -Co $x | Select NumberOfLogicalProcessors
      $a1 = gwmi Win32_WmiSetting -Co $x
      gwmi Win32_OperatingSystem -Co $x | Select @{n='OS Name';e={$_.caption}},Version,@{n='OS BuildVersion:';e={$a1.BuildVersion}}
      gwmi Win32_NetworkAdapterConfiguration -Co $x | Where {$_.IPEnabled}
      gci "\\$x\c$\Users" | Sort LastWriteTime -Descending | Select @{n='Last User to login:';e={$_.Name}},@{n='Last login:';e={$_.LastWriteTime}} -first 1
      gwmi Win32_ComputerSystem -Co $x | Select @{n='Nr. of cores:';e={$_.NumberOfLogicalProcessors}},@{n='Total RAM';e={$_.totalphysicalmemory / 1GB -as [int]}}
      gwmi win32_processor -fi "deviceid='CPU0'"} 
    9{gwmi win32_logicaldisk -fi "drivetype=3" -Co (Read-Host "Please input the computer name") | ft DeviceID,@{n='Size(GB)';e={$_.size/1GB -as [int]}},@{n='FreeSpace(GB)';e={$_.freespace/1GB -as [int]}},@{n='FreeSpace(%)';e={$_.freespace/$_.size*100 -as [int]}}  -autosize }
    10{gwmi win32reg_addremoveprograms -ComputerName (Read-Host "Please input the computer name") | Select DisplayName,InstallDate,Version,Publisher  | Out-GridView}
    11{gci -Pa (Read-Host "Input the path (local/UNC) you want to scan") -Recurse -Directory | Get-NTFSAccess | Select * | Out-GridView }
    12{Get-ADUser -Id (Read-Host "Input user ID")}
    13{Get-ADPrincipalGroupMembership -id (Read-Host "Input user ID") | ft Name,GroupScope -AutoSize }
    14{Get-ADGroup -Id (Read-Host "Input Group name")}
    15{Get-NTFSEffectiveAccess -Pa (Read-Host "Input location") -Acc (Read-Host "Input user ID") | fl * }
    16{exit}
    "a"{"This app is to be used ONLY by NTT Data. If not, -."}
    "exit"{exit}
    "quit"{exit}
    "q"{exit}
}

Write-Host ""
Write-Host ""
$reiteration = Read-Host "Press ENTER to reiterate commands..."
Clear-Host
}
