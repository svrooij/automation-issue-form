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
  $token = $(az account get-access-token --resource https://graph.microsoft.com) | ConvertFrom-Json
  if (-null -eq $token) {
    Write-Host "Failed to get access token. Please check your Azure CLI authentication."
    exit 1
  }
  $graphToken = $token.accessToken
  # Connect to Microsoft Graph with the token as secure string
  Connect-MgGraph -AccessToken $graphToken -NoWelcome -ErrorAction Stop

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
