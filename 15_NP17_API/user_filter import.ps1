$NP_server = "smuc8768:4993"
$application_id = "384430e0-5a9b-491c-aa6c-b8949c551bbc"
$connection_id = "f5871a98-a656-47aa-abe7-bad861f0197c"
$group_id = "c75ac6c0-fe06-4935-a385-040bc2241cd5"
$role_id = "937759dc-56a6-4146-b519-88a7916c2152"
$file_import = "E:\NP_Storage\NP_Projects\PUK_Reporting\03_Recipients\PROD\FolderRecipientsCountry.txt"


#perform NTLM authentication
$auth = Invoke-WebRequest -uri https://$NP_server/api/v1/login/ntlm -UseDefaultCredentials -SessionVariable session

# extracting authentication token
$start_token = $auth.RawContent.IndexOf('NPWEBCONSOLE_XSRF-TOKEN%3A') + 26
$end_token   = $auth.RawContent.IndexOf('3D') - 1
$token = $auth.RawContent.Substring($start_token,$end_token-$start_token) + "="
$token = $token.Replace('%2B','+')
$token = $token.Replace('%2F','/')

$recipients = Get-Content $file_import

Write-Output "Total no. to import: " + $recipients.Count ;

#create header for POST/PUT requests
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$header.Add("X-XSRF-TOKEN", "$token")
$header.Add("Content-Type", "application/json; charset=utf-8")

for ($i=1; $i -le $recipients.Count - 1; $i++) {


$id = $recipients[$i].Split("`t")[1]
$folder_name = $recipients[$i].Split("`t")[1]
$subfolder_name = $recipients[$i].Split("`t")[2]
$full_name = $recipients[$i].Split("`t")[3]
$filter = $recipients[$i].Split("`t")[4]
$group = $recipients[$i].Split("`t")[5]
$clearFilterRefList = $recipients[$i].Split("`t")[6]

$end_filter_field = $recipients[$i].Split("`t")[4].IndexOf('={')
$filter_field = $recipients[$i].Split("`t")[4].Substring(0,$end_filter_field)

$start_filter_value = $recipients[$i].Split("`t")[4].IndexOf('={') + 2
$end_filter_value = $recipients[$i].Split("`t")[4].IndexOf('<IsNumeric')
$filter_value = $recipients[$i].Split("`t")[4].Substring($start_filter_value,$end_filter_value-$start_filter_value)


#create body for USER for POST/PUT request in JSON format
$body_user = @{"email"= "$subfolder_name@domain.local";
          "password"= "test123";
          "enabled"= "false";
          "username"= "$subfolder_name";
          #"domainAccount" = "muc\qxo3974";
          "timezone"= "Europe/Bucharest";
          "locale"= "en";
          "folder"= "$full_name";
          "subFolder" = "$subfolder_name"
          } | ConvertTo-Json

$user = Invoke-WebRequest -uri https://$NP_server/api/v1/users -Method Post -WebSession $session -Headers $header -Body $body_user

#extracting ID of newly created user
$start_userid = $user.RawContent.IndexOf('/users/') + 7
$end_userid = $user.RawContent.IndexOf('Set-Cookie:') - 2
$userid = $user.RawContent.Substring($start_userid,$end_userid-$start_userid)

#create body for Filter for POST/PUT request in JSON format
$body_filter = @"
{   "appId":"$application_id",
    "enabled":"false",
    "name":"$subfolder_name",
    "description":"sample description for $subfolder_name",
    "fields":[{"connectionId":"$connection_id",
              "name":"$filter_field",
              "overrideValues":"false",
              "values":[{"value":"$filter_value",
                        "type":"text"
                       }]
             }]
}
"@

$filter = Invoke-WebRequest -uri https://$NP_server/api/v1/filters -Method Post -WebSession $session -Headers $header -Body $body_filter

$start_filterid = $filter.RawContent.IndexOf('/filters/') + 9
$end_filterid = $filter.RawContent.IndexOf('Set-Cookie:') - 1
$filterid = $filter.RawContent.Substring($start_filterid,$end_filterid-$start_filterid)

$body_filter_PUT = @"
["$filterid"]
"@

# allocate Filter to User
$filter_user = Invoke-WebRequest -uri https://$NP_server/api/v1/users/$userid/filters -Method Put -WebSession $session -Headers $header -Body $body_filter_PUT

$body_group_PUT = @"
["$group_id"]
"@

# assign User to PROD Group
$user_group = Invoke-WebRequest -uri https://$NP_server/api/v1/users/$userid/groups -Method Put -WebSession $session -Headers $header -Body $body_group_PUT 


$body_role_PUT = @"
["$role_id"]
"@

#assign User role to the user
$role_user = Invoke-WebRequest -uri https://$NP_server/api/v1/users/$userid/roles -Method Put -WebSession $session -Headers $header -Body $body_role_PUT

Write-Output $i ;

}