$excel = New-Object -ComObject excel.application
$excel.Application.Visible = $true
$excel.DisplayAlerts = $false
$book = $excel.Workbooks.Add()
$sheet = $book.Worksheets.Item(1)
$sheet.name = 'Users'
$sheet.Activate() | Out-Null

$row = 1
$column = 1

$headers = "E-mail","Username","Password","Domain Account","Enabled","Time Zone","Locale","NickName","Title",`
           "Company","Job Title","Department","Office","Filters","Groups","Roles"
foreach ($header in $headers) {
        $sheet.Cells.Item($row,$column) = $header
        $column ++
    }

$column = 1
$row = 2

$Users = Get-ADUser -filter * -Properties *

foreach($User in $Users) {

    if ($User.EmailAddress -like "*@*" -and $User.Company -ne $null -and $User.Enabled -eq "True" ) { # validation for real people users, they must have email and company in AD
        $sheet.Cells.Item($row,1) = $User.EmailAddress            # email
        $sheet.Cells.Item($row,2) = $User.CN                      # username
        $sheet.Cells.Item($row,3) = "Test123"                     # password
        $sheet.Cells.Item($row,4) = "ebs\" + $User.SamAccountName # domain account
        $sheet.Cells.Item($row,5) = "True"                        # enabled
        $sheet.Cells.Item($row,6) = "Europe/Bucharest"            # time zone
        $sheet.Cells.Item($row,7) = "en"                          # locale
        $sheet.Cells.Item($row,8) = $User.CN                      # nickname
        $sheet.Cells.Item($row,9) = $null                         # title, Mr./Mrs.
        $sheet.Cells.Item($row,10) = $User.Company                # company
        $sheet.Cells.Item($row,11) = $User.Title                  # job title
        $sheet.Cells.Item($row,12) = $User.Department             # department
        $sheet.Cells.Item($row,13) = $User.Office                 # office
        #$sheet.Cells.Item($row,14) = $null                        # filters
        #$sheet.Cells.Item($row,15) = $null                        # groups
        #$sheet.Cells.Item($row,16) = $null                        # roles

        $row ++
    }
}
