# Load required assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form_MainMenu = New-Object System.Windows.Forms.Form
    $Form_MainMenu.Size = New-Object System.Drawing.Size(832,528)
    $Form_MainMenu.Text = "Server Management Tool"
    $Form_MainMenu.MaximizeBox = $false
    $Form_MainMenu.FormBorderStyle = "FixedDialog"
    $Form_MainMenu.StartPosition = "CenterScreen"
    $Form_MainMenu.Font = "Segoe UI"

$label_ResultBox = New-Object System.Windows.Forms.Label
    $label_ResultBox.Location = New-Object System.Drawing.Size(380,8)
    $label_ResultBox.Size = New-Object System.Drawing.Size(438,450)
    $label_ResultBox.BorderStyle = "FixedSingle"
    $label_ResultBox.TextAlign = "TopLeft"
    $label_ResultBox.Text = {Results:
    
    }
    $Form_MainMenu.Controls.Add($label_ResultBox)


$button_execute = New-Object System.Windows.Forms.Button
    $button_execute.Location = New-Object System.Drawing.Size(8,8)
    $button_execute.Size = New-Object System.Drawing.Size(100,30)
    $Form_MainMenu.Controls.Add($button_execute)









# Show form with all of its controls
$Form_MainMenu.Add_Shown({$Form_MainMenu.Activate()})
[Void] $Form_MainMenu.ShowDialog()