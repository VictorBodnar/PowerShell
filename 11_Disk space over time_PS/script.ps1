$servers = "smuc7194","smuc7082"#,"sw061170","sw070324","sw340659","sw021429","sw100056","sw090320"

foreach ($server in $servers) {

$inventoryPath = "E:\Administration\binaries\Disk Space over time\_data_files\" # Where you want the inventory text files created
$FileDir =  "\\$server\e$\qv_projects"

$fso = New-Object -comobject Scripting.FileSystemObject

$OutFileName = $FileDir.Substring(3).Replace("\","-").Replace(" ","-")
    
$OutFolderInfo = $inventoryPath + "Folders_$server.csv"
$OutFileInfo = $inventoryPath + "Files_$server.csv"

Del $OutFolderInfo -ErrorAction SilentlyContinue
Del $OutFileInfo -ErrorAction SilentlyContinue

Add-Content -Value  "Folder Path|LastWriteTime|Size|FileCount|Levels|CleanFolderName|Choice" -Path $OutFolderInfo 
Add-Content -Value  "Folder Path|FileName|LastWriteTime|Size|Extension" -Path $OutFileInfo     
$Folders = dir $FileDir -recurse | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
    if($Folder -ne $null){
            $CleanFolderName = $Folder.Fullname.Replace(",","") #Remove commas in folder names
            $FSOFolder = $fso.GetFolder($Folder.Fullname)
            $FolderSize = "{0:N2}" -f ($FSOFolder.size / 1MB) 
            $FolderFileCount = $FSOFolder.Files.Count 
            $OutInfo = $CleanFolderName + "|"  + $Folder.LastWriteTime  + "|" + $FolderSize +"|" + $FolderFileCount + "|" + $CleanFolderName.split("\").Length+ "|" + $CleanFolderName.split("\")[$CleanFolderName.split("\").Length-1]
            Add-Content -Value $OutInfo -Path $OutFolderInfo
            if($FolderFileCount -gt 0){
                $Files = dir $Folder.Fullname | where {$_.psiscontainer -eq $false}
                if($Files -ne $null){
                    Foreach ($File in $Files){
                            $FileSize = "{0:N2}" -f ($File.Length / 1MB) 
                                $OutInfo = $CleanFolderName + "|" + $File.Name  + "|" + $File.LastWriteTime + "|" + $FileSize + "|" + $File.Extension
                                Add-Content -Value $OutInfo -Path $OutFileInfo
                         }
            }
        } 
    }
}}