$body = @"
### Select the admin action

Load user data

### User

demo-user-1@CodingStephan.onmicrosoft.com

### Reason for action

Can we have the user details of this user please?
"@

# Extract the values from the body for each section
$sections = $body -split "\n\n" | ForEach-Object { $_.Trim() }
$sections = $sections | Where-Object { $_ -ne "" } # Remove empty sections

$sectionValues = @{}
foreach ($section in $sections) {
    $lines = $section -split "\n" | ForEach-Object { $_.Trim() }
    $sectionName = $lines[0].Replace("### ", "").Trim().ToLower()
    $sectionName = $sectionName -replace '[^a-zA-Z0-9_]', '_' # Remove special characters
    $sectionContent = $lines[1..($lines.Count - 1)] -join "`n"
    $sectionValues[$sectionName] = $sectionContent
}

if ($sectionValues.ContainsKey("select_the_admin_action")) {
    ...
}