$body = @"
### Select the admin action

Load user data

### User

demo-user-1@CodingStephan.onmicrosoft.com

### Reason for action

Can we have the user details of this user please?
"@

# Extract the values from the body for each section
$lines = $body -split "\n" | ForEach-Object { $_.Trim() }
$lines = $lines | Where-Object { $_ -ne "" } # Remove empty sections

$sectionValues = @{}
for ($i = 0; $i -lt $lines.Count; $i++) {
  # if line starts with ###, it is a section header
  if ($lines[$i].StartsWith("### ")) {
    $sectionName = $lines[$i].Remove(0,4).Trim().Replace(" ", "_").ToLower()
    $sectionValues[$sectionName] = ""
    $x = $i+1 # Move to the next line
    # Collect all lines until the next section header or end of array
    while ($x -lt $lines.Count -and $lines[$x] -notmatch "^### ") {
      # Append the line to the section value
      $sectionValues[$sectionName] += $lines[$x].Trim()
      $x++
    }
  }
}

Write-Host "Extracted Values:"
foreach ($key in $sectionValues.Keys) {
    Write-Host "$key > $($sectionValues[$key])"
}