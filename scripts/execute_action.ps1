param (
    [Parameter(Mandatory=$true)]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$User
)

BEGIN {
  Write-Host "Executing action: $Action for user: $User"
}

PROCESS {
  $graphToken = Get-AzAccessToken -ResourceUrl 'https://graph.microsoft.com' -AsSecureString
  # Connect to Microsoft Graph with the token as secure string
  Connect-MgGraph -AccessToken $graphToken.Token -NoWelcome -ErrorAction Stop

  if($Action == "Load user data") {
    $userdata = Get-MgUser -UserId $User -Property DisplayName, Id, AccountEnabled -ErrorAction Stop
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "### User data loaded successfully`n"
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "- DisplayName: $($userdata.DisplayName)"
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "- Id: $($userdata.Id)"
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "- AccountEnabled: $($userdata.AccountEnabled)`n"
  } else {
    Write-Host "Action not recognized. Please check the action name."
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "## Action not recognized`n"
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "- Action: $Action`n"
  }

  Disconnect-Graph -ErrorAction Continue
}
