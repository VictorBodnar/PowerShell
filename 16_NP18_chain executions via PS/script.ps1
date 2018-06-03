$NP_server = "vmt-ebs-073:4993"
$refresh_task_id = "82c4b7a9-20af-4b56-874c-bc6107a40480"
#$application_id = "384430e0-5a9b-491c-aa6c-b8949c551bbc"
#$connection_id = "f5871a98-a656-47aa-abe7-bad861f0197c"
#$group_id = "c75ac6c0-fe06-4935-a385-040bc2241cd5"
#$role_id = "937759dc-56a6-4146-b519-88a7916c2152"

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

$refresh_task_start = Invoke-WebRequest -uri https://$NP_server/api/v1/tasks/$refresh_task_id/executions -Method Post -WebSession $session -Headers $header | ConvertFrom-Json

$refresh_task_execution_id = $refresh_task_start.data.id

$refresh_task_status = Invoke-WebRequest -uri https://$NP_server/api/v1/tasks/$refresh_task_id/executions/$refresh_task_execution_id -WebSession $session | ConvertFrom-Json

$refresh_task_progress = $refresh_task_status.data.progress