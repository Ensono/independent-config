
function Get-ProjectID() {

    [CmdletBinding()]
    param (

        [string]
        # Server to authenticate against
        $Server = $env:CONFIG_SERVER,

        [string]
        # ID of the organisation id
        $OrganisationID,

        [string]
        # Name of the project to retrieve
        $Name,

        [string]
        # Token to use for authentication
        $Token
    )

    # Configure the headers for the request
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = ("Bearer {0}" -f $Token)
    }

    # Build up the URI
    $uri = "{0}/api/v2/organizations/{1}/workspaces" -f $Server, $OrganisationID

    $data = Invoke-RestMethod -Uri $uri -Headers $headers

    foreach ($workspace in $data.workspaces) {

        if ($workspace.name -eq $Name) {
            $id = $workspace.id
        }
    }

    return $id
}
