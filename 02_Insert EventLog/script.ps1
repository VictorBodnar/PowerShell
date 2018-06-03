$LogSource = "FasAna gfs"
$date = Get-Date

New-EventLog -LogName Application -Source $LogSource -ea SilentlyContinue

$LogMessage = "Task processing crashed on $date "

Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 9999 -Message $LogMessage