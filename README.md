# automation-issue-form

An experiment to test out admin workflows based on Issue forms

## Issue Forms

You can create your own issue forms by creating a yaml file in the `.github/ISSUE_TEMPLATE` directory. The file name will be used as the form name. The form will be displayed when a user clicks on the "New issue" button in the Issues tab of your repository.

This repository contains [this issue form](.github/ISSUE_TEMPLATE/admin_action.yml) as an example. Check out [this page](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms?wt.mc_id=SEC-MVP-5004985) for more information on how to create your own issue forms.

In the sample I used a dropdown menu and a text field. Check out the form by creating a [new issue](https://github.com/svrooij/automation-issue-form/issues).

Suggestions for the `Select the admin action` dropdown are:

- `Add user to group`
- `Remove user from group`
- `Make global admin` - Make a user a global admin in Entra ID

> [!IMPORTANT]
> For obvious reasons, only the `Load user data` action will work, but it shows how to securely connect to the Graph API and execute a script on demand. Monitoring the use of the created app is key in this scenario.

## Automation

If you created an issue using the form, a [workflow](#workflow) will be triggered. Executing the requested action and eventually closing the issue.

### Workflow

The [workflow](.github/workflows/issue-created.yml) is defined in the `.github/workflows/issue-created.yml` file. It will be triggered when a new issue is created using the form. The workflow will parse the content of the issue and execute a script based on the selected action.

1. First action will block all executions if the issue is not created by myself. This is to prevent abuse of the workflow by other users. You should change this to something more reasonable for your use case. For instance keep a file in this repository and check with that. Or use a secret to check if the user is allowed to execute the action.
1. Parsing the content of the issue body using PowerShell. Feel free to reuse this code in your own workflow.
1. Call `azure/login@v2` to authenticate to Azure. This step uses [federated credentials](#federated-credentials) and only needs `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` to be set as secrets in your repository.
1. Execute [this script](./scripts/execute_action.ps1) to execute the requested action. Mind you this script takes the action and the username that were filled in in the issue form.
1. [Close and lock the issue](#closing-the-issue).

### Federated credentials

To authenticate to the Graph API, you'll need to create [follow the steps in the Maester docs](https://maester.dev/docs/monitoring/github#set-up-the-github-actions-workflow), using just the permissions you want to give to this workflow. Mine is only configured with `User.Read.All` so it cannot do much harm is someone gets access to it.

More details on how federated credentials actually work, check out [this blog post](https://svrooij.io/2023/11/07/github-actions-federated-credentials-explained/).

> [!TIP]
> Using federated credentials means there is no secret (that can expire) needed. You don't have to renew a secret every x days. And because there is no secret (with pretty powerful permissions) it cannot be leaked.

### Closing the issue

A workflow can respond to issues by listening for the `opened` event. We don't want to end up with an endless list of issues, so we want to close the issue after the action is executed.

```yml
# listen for the issue opened event
on:
  issues:
    types:
      - opened

jobs:
  handle-issue:
    permissions: # Add extra permissions fo the `GITHUB_TOKEN` in this workflow
      issues: write # Required to lock and close issues
      id-token: write # Required to use the ID token for Azure login
```

Once you have set the correct permissions, you can execute the github cli and do whatever you want with the issue. In this case, we want to lock and close the issue.

```yml
      - name: 🔒 Lock and close issue
        if: always()
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh issue close "${{ github.event.issue.number }}" --comment "Some closing comment" --repo "${{ github.repository }}"
          gh issue lock "${{ github.event.issue.number }}" --reason "resolved" --repo "${{ github.repository }}"
```

## Production ready?

This is a proof of concept, I'm not suggesting to use this in production. But I like to concept of using issue forms to trigger workflows and to do stuff automatically.
