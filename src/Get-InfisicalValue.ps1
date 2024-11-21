
. ./infisical/Get-Token.ps1
. ./infisical/Get-ProjectID.ps1

function Get-InfisicalValue() {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Alias("Server")]
        [string]$InfisicalServer,

        [Alias("Org")]
        [string]
        # ID of the organisation in Infisical
        $OrganisationID = $env:INFISICAL_ORG_ID,

        [Parameter(Mandatory=$true)]
        [string]$Project,

        [string]
        # Name of the item to retrieve
        $Name
    )

    # Get the token to use for API authentication
    Write-Host "Getting API Authentication Token"
    $token = Get-Token -Server $InfisicalServer

    # Configure the headers for the request
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = ("Bearer {0}" -f $token)
    }

    # Set the name of the environment to use in Infisical
    # This is a static value
    $_environment = "default"

    # Determine if the project is a GUID, e.g. the ID of the project, or
    # a name. If it is a name then call the function to get the ID of the project
    $ObjectGuid = [System.Guid]::Empty

    $IsGUID = [System.Guid]::TryParse($Project, [ref]$ObjectGuid)

    if (!$IsGUID) {

        # Create a hashtable to splat the parameters into the function
        $splat = @{
            Server = $Server
            OrganisationID = $OrganisationID
            Name = $Project
            Token = $token
        }

        $Project = Get-ProjectID @splat
    }

    # Set the body to use as the query request
    $parts = $Name -split "/"
    $Name = $parts[-1]

    # create an array to hold the query parts
    $query = @(
        ("workspaceId={0}" -f $Project),
        ("environment={0}" -f $_environment),
        "recursive=true"
    )

    $uriPath = "{0}/api/v3/secrets/raw" -f $Server

    # if there is one part to the path, it is the name of the folder that we need to look for
    # and recursively get all the values
    if ($parts.length -eq 1) {
        $query += ("secretPath=%2f{0}" -f $path)
    }

    # if there is more than one part to the path, it is the folder and the name of the secret that
    # we are after
    if ($parts.length -gt 1) {
        $path = $parts[0..($parts.length - 2)] -join "/"
        $query += ("secretPath=%2f{0}" -f $path)
        $uriPath += "/{0}" -f $Name
    }

    # Build up the URI
    $uri = "{0}?{1}" -f $uriPath, ($query -join "&")

    $splat = @{
        Uri = $uri
        Headers = $headers
        Method = "Get"
    }


    $data = Invoke-RestMethod @splat

    if ($data.secret.length -eq 1) {
        $return = @{$data.secret.secretKey = $data.secret.secretValue}
    } elseif ($data.secrets.length -gt 0) {

        $return = @{}

        # iterate around the secrets that have been returned
        foreach ($secret in $data.secrets) {
            $return[$secret.secretKey] = $secret.secretValue
        }

    }

    return $return
}
