Import-Module .\_scripts\Get-InstalledSoftware.ps1 # from https://community.spiceworks.com/scripts/show/2170-get-a-list-of-installed-software-from-a-remote-computer-fast-as-lightning

$servers = Get-Content .\server_list.txt
$output_location="C:\Users\axo3976\Desktop\PS_commands\Output"

ForEach ($s in $servers) {
    #create files with the shares for each computer in the list
    Get-WmiObject -class Win32_Share -ComputerName $s | Out-File $output_location"\Shares\share_list_$s.txt"

    #create files with the local groups mounted on each computer in the list
    Get-WMIObject win32_group -filter "LocalAccount='True'" -ComputerName $s | Format-Table caption,name,domain -AutoSize | Out-File $output_location"\Groups\groups_list_$s.txt"

    # create files with local group memberships for each computer in the list
    Invoke-Command -ScriptBlock {
    [ADSI]$S = "WinNT://$($env:computername)"
    $S.children.where({$_.class -eq 'group'}) |
    Select @{Name="Name";Expression={$_.name.value}},
    @{Name="Members";Expression={
    [ADSI]$group = "$($_.Parent)/$($_.Name),group"
    $members = $Group.psbase.Invoke("Members")
    ($members | ForEach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}) -join ";"}
    }
    } -ComputerName $s |
    Select Name,Members |
    Out-File $output_location"\Groups\groups_members_$s.txt"

    # get system specs for all computers in list
    $Bios = Get-WmiObject win32_bios -Computername $s
    $Hardware = Get-WmiObject Win32_computerSystem -Computername $s
    $Sysbuild = Get-WmiObject Win32_WmiSetting -Computername $s
    $OS = Get-WmiObject Win32_OperatingSystem -Computername $s
    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $s | Where-Object {$_.IPEnabled}
    $cpu = Get-WmiObject Win32_Processor  -computername $s
    $username = Get-ChildItem "\\$s\c$\Users" | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime -first 1
    $totalMemory = [math]::round($Hardware.TotalPhysicalMemory/1024/1024/1024, 2)
    $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime) 
    $nrcores = Get-WmiObject Win32_ComputerSystem -ComputerName $s | Select NumberOfLogicalProcessors
    $IPAddress  = $Networks.IpAddress[0]
    $systemBios = $Bios.serialnumber
    $OutputObj  = New-Object -Type PSObject
    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $s.ToUpper()
    $OutputObj | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $Hardware.Manufacturer
    $OutputObj | Add-Member -MemberType NoteProperty -Name Model -Value $Hardware.Model
    $OutputObj | Add-Member -MemberType NoteProperty -Name System_Type -Value $Hardware.SystemType
    $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System -Value $OS.Caption
    $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System_Version -Value $OS.version
    $OutputObj | Add-Member -MemberType NoteProperty -Name Operating_System_BuildVersion -Value $SysBuild.BuildVersion
    $OutputObj | Add-Member -MemberType NoteProperty -Name Serial_Number -Value $systemBios
    $OutputObj | Add-Member -MemberType NoteProperty -Name IP_Address -Value $IPAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name User_Last_Login -Value $username.LastWriteTime
    $OutputObj | Add-Member -MemberType NoteProperty -Name Nr_Virtual_Processors -Value $nrcores
    $OutputObj | Add-Member -MemberType NoteProperty -Name Total_Memory_GB -Value $totalMemory
    $OutputObj | Add-Member -MemberType NoteProperty -Name Last_ReBoot -Value $lastboot
    $OutputObj | Export-Csv .\Output\System_specs_$(get-date -f dd-MM-yyyy).csv -Append -NoTypeInformation

    #get disk space usage on all computers in list
    gwmi win32_logicaldisk -ComputerName $s | Format-Table DeviceId, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}} -AutoSize | Out-File .\Output\DiskUsage\disk_usage_$s.txt
                  
    #get installed programs on all computers in list
    Get-InstalledSoftware $s | Out-File .\Output\InstalledPrograms\programs_$s.txt

}
