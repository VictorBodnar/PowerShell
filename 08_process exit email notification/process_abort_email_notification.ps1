$process_id = Read-Host ("Process ID")

while(1)
 {
  #it will check the current minutes 
  $process =(Get-Process -Id $process_id -ErrorAction SilentlyContinue)
   #connect() function will call after every 10 mins 
  if($process -eq $null )
 {  
   Send-MailMessage -To victor.bodnar.bp@nttdata.ro -From victor.bodnar.bp@nttdata.ro -Subject "NP Alert" -Body "The NP execution has finished" -SmtpServer 10.224.2.7 -Port 587 
   break
 }
 }