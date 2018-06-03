$NP_server = "smuc8768:4993"
$refresh_task_id = "34b6ecdd-67cd-4f2d-8c58-b91e18630624"
$publish_task_id = "410a4236-5a9a-4206-a26a-b9a1cb748c16"


#perform NTLM authentication
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$auth = Invoke-WebRequest -uri https://$NP_server/api/v1/login/ntlm -UseDefaultCredentials -SessionVariable session

# extracting authentication token
$start_token = $auth.RawContent.IndexOf('NPWEBCONSOLE_XSRF-TOKEN%3A') + 26
$end_token   = $auth.RawContent.IndexOf('3D') - 1
$token = $auth.RawContent.Substring($start_token,$end_token-$start_token) + "="
$token = $token.Replace('%2B','+')
$token = $token.Replace('%2F','/')

#create header for POST/PUT requests
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$header.Add("X-XSRF-TOKEN", "$token")
$header.Add("Content-Type", "application/json; charset=utf-8")

$refresh_task_start = Invoke-WebRequest -uri https://$NP_server/api/v1/connections/$refresh_task_id/reload -Method Post -WebSession $session -Headers $header | ConvertFrom-Json

$refresh_status = $null

while ($refresh_status -ne "Generated") {
cls
$status = Invoke-WebRequest -uri https://$NP_server/api/v1/connections/$refresh_task_id -WebSession $session -Headers $header | ConvertFrom-Json
$refresh_status = $status.data.cacheStatus
Write-Host "Status is"$refresh_status "...";
Start-Sleep -Seconds 3
}
cls
Write-Host "Status is"$refresh_status;

$publish_task_start = Invoke-WebRequest -uri https://$NP_server/api/v1/tasks/$publish_task_id/executions -Method Post -WebSession $session -Headers $header | ConvertFrom-Json


