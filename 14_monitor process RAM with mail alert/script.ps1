$systemRAM = Get-WmiObject win32_computersystem
$processes = Get-Process -name qvs

while (1) {
foreach  ($process in $processes) {
     if ($process.WorkingSet64/$systemRAM.TotalPhysicalMemory -ge 0.8) {
     Send-MailMessage -From "MUC.Dev@bmw.de" -to "victor.bodnar.bp@nttdata.ro" -Subject "QVS Ram Usage alert. Now at > 80%" -SmtpServer smtp.muc;
     }
}
Start-Sleep -Seconds 10;
}