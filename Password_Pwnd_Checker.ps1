# Add types for Windows Forms and Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to calculate hash SHA-1 of a string
function Get-SHA1Hash {
param (
[Parameter(Mandatory=$true)]
[string]$InputString
)
$sha1 = [System.Security.Cryptography.SHA1]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
$hashBytes = $sha1.ComputeHash($bytes)
$hashString = [BitConverter]::ToString($hashBytes) -replace '-', ''
return $hashString.ToUpper()
}

# Function to calculate password score (out of 6 points)
function Get-PasswordStrength {
param (
[Parameter(Mandatory=$true)]
[string]$Password
)
$score = 0

# Criterion 1: Minimum length of 8 characters
if ($Password.Length -ge 8) {
$score++
}

# Criterion 2: Advanced length, 12 or more characters
if ($Password.Length -ge 12) {
$score++
}

# Criterion 3: presence of lowercase letters
if ($Password -match '[a-z]') {
$score++
}

# Criterion 4: presence of capital letters
if ($Password -match '[A-Z]') {
$score++
}

# Criterion 5: presence of numbers
if ($Password -match '\d') {
$score++
}

# Criterion 6: presence of special characters
if ($Password -match '[!@#$%^&*(),.?":{}|<>]') {
$score++
}

return $score
}

# Function to interpret the score in a qualitative evaluation
function Interpret-Strength {
param (
[Parameter(Mandatory=$true)]
[int]$Score
)
if ($Score -le 2) {
return "weak"
}
elseif ($Score -le 4) {
return "Medium"
}
else {
return "Strong"
}
}

# Feature to check if your password has been compromised via Have I Been Pwned
function Check-PwnedPassword {
param (
[Parameter(Mandatory=$true)]
[string]$Password
)
# Calculate the SHA-1 hash of the password
$sha1Hash = Get-SHA1Hash -InputString $Password
$prefix = $sha1Hash.Substring(0,5)
$suffix = $sha1Hash.Substring(5)

$url = "https://api.pwnedpasswords.com/range/$prefix"

try {
# Make the request to the API
$response = Invoke-RestMethod -Uri $url -Method Get
# The API returns a string with lines of the format "Suffix:Count"
$lines = $response -split "`n"
foreach ($line in $lines) {
$line = $line.Trim()
if ($line -eq "") { continue }
$parts = $line -split ":"
if ($parts[0].Trim() -eq $suffix) {
return [int]$parts[1].Trim()
}
}
return 0
}
catch {
return $null
}
}

# --- Creation of the graphical interface ---

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pwd Pwnd Checker"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

# Instruction Label 
$labelInstruction = New-Object System.Windows.Forms.Label
$labelInstruction.Location = New-Object System.Drawing.Point(10, 20)
$labelInstruction.Size = New-Object System.Drawing.Size(380, 20)
$labelInstruction.Text = "Insert the password to verify:"

# TextBox for password insert (masked)
$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(10, 50)
$textBoxPassword.Size = New-Object System.Drawing.Size(360, 25)
$textBoxPassword.PasswordChar = '●'

# Button "Verify"
$buttonCheck = New-Object System.Windows.Forms.Button
$buttonCheck.Location = New-Object System.Drawing.Point(10, 80)
$buttonCheck.Size = New-Object System.Drawing.Size(100, 30)
$buttonCheck.Text = "Verify"

# Score Label
$labelScore = New-Object System.Windows.Forms.Label
$labelScore.Location = New-Object System.Drawing.Point(10, 120)
$labelScore.Size = New-Object System.Drawing.Size(380, 20)
$labelScore.Text = "Score: "

# Label strenght password score
$labelStrength = New-Object System.Windows.Forms.Label
$labelStrength.Location = New-Object System.Drawing.Point(10, 150)
$labelStrength.Size = New-Object System.Drawing.Size(380, 20)
$labelStrength.Text = "Strenght: "

# Label status Have I Been Pwned
$labelHIBP = New-Object System.Windows.Forms.Label
$labelHIBP.Location = New-Object System.Drawing.Point(10, 180)
$labelHIBP.Size = New-Object System.Drawing.Size(380, 30)
$labelHIBP.Text = "Status Have I Been Pwned: "

# Icona eye password

    $iconBase64 = "iVBORw0KGgoAAAANSUhEUgAAAB0AAAAdCAQAAAD8mq+EAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAJcEhZcwAAA7EAAAOxAfWD7UkAAAAHdElNRQfkCxQOOgomSBiAAAABvElEQVQ4y+3TMU9TYRgF4KdFAiQFqguDGhIZGARJLBBow6Q/gMBA/Sk4sejYCSchQlhgKEQ3EhsG0rgokd4W0wRcdDYdWAhRHPisBWslzpzp3vPm3vc75zuHa1wBbS1mcW04+9s49gfT7o77htxzS7tT33xWUfHFaatPkx6bMeGuY+9FapKGjUr46p1Nb9Wa7e80a0dZ5EReWmedT8s7UVK2Y7bO19FvyaHnpu3L6bk07ZGzb9ozh5b0N47GFRVM6rBiU2+TM/Xa8kqHSQVF47/ojMiyPkyqmqrrzlrwRDK8T6maQJ9lkQyk7FnUDZ7a1hW2rDrw2ier4RRdts2Dbov2jLJrPfw5Zk0u7MiqeCgmpSIbuJy1cCNJ63bjhm0Ey+MSdfMHHSk5s+/IYOBqEuLhacNwXGQubP3huK6sasCImBEDqoG76dj3sHVOdK71RdA636B1xYE3LbSmLjo80eBwr6wF2aYOl84dhjFFBWkdVmy1vNe0gqKxi2l6+Y80fWyepvOszjRkOBM00yUj70SkbMfM7wxfbs4js6E5H5TUJD2QCs3JKzQ2p1lfbxu6Sl9bIe5GiMA1/h8/AZgPjWSiPy0xAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIwLTExLTIwVDE0OjU4OjEwLTA1OjAweD45zAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMC0xMS0yMFQxNDo1ODoxMC0wNTowMAljgXAAAAAZdEVYdFNvZnR3YXJlAHd3dy5pbmtzY2FwZS5vcmeb7jwaAAAAAElFTkSuQmCC"
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
    $stream.Write($iconBytes, 0, $iconBytes.Length);
    $iconImage       = [System.Drawing.Image]::FromStream($stream, $true)
    
    
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Width =  $iconImage.Size.Width = 30;
    $pictureBox.Height =  $iconImage.Size.Height = 30;

    $pictureBox.Location = New-Object System.Drawing.Size(330,75) 
    $pictureBox.Image = $iconImage;
    

    $pictureBox.add_MouseDown({EyePasswordClickDown})
    $pictureBox.add_MouseUp({EyePasswordClickup})
    $pictureBox.Add_MouseEnter({EyePasswordOver})
    $pictureBox.Add_MouseLeave({$pictureBox.BackColor = ""})

# Blue background on eye icon when mouse over

function EyePasswordOver (){
    
    $pictureBox.BackColor = "lightblue"

}

# Show password on click 

function EyePasswordClickDown (){
   
    
    $TextBoxPassword.PasswordChar = 0
    
    

}

# Mask password 

function EyePasswordClickup(){
    $TextBoxPassword.PasswordChar = '●'
    


}

# Click button event
$buttonCheck.Add_Click({
$password = $textBoxPassword.Text
if ([string]::IsNullOrEmpty($password)) {
[System.Windows.Forms.MessageBox]::Show("Inserisci una password!", "Errore", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
return
}

# Calculate score and password strenght
$score = Get-PasswordStrength -Password $password
$strength = Interpret-Strength -Score $score

# verify presence of compromised password
$pwnedCount = Check-PwnedPassword -Password $password

$labelScore.Text = "Score: " + $score
$labelStrength.Text = "Strenght: " + $strength

if ($pwnedCount -eq $null) {
$labelHIBP.Text = "Status Have I Been Pwned: Errore to access to API"
}
elseif ($pwnedCount -gt 0) {
$labelHIBP.Text = "Status Have I Been Pwned: Password found in $pwnedCount breach. Change it!"
}
else {
$labelHIBP.Text = "Status Have I Been Pwned: 
Password is NOT compromised."
}
})

# Add controls form
$form.Controls.Add($labelInstruction)
$form.Controls.Add($textBoxPassword)
$form.Controls.Add($buttonCheck)
$form.Controls.Add($labelScore)
$form.Controls.Add($labelStrength)
$form.Controls.Add($labelHIBP)
$form.Controls.Add($pictureBox)

# Show dialog
[void]$form.ShowDialog()