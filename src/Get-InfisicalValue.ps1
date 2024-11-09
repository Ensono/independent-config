
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
    $token = Get-Token -Server $Server

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
    if ($parts.length -gt 1) {

        $path = $parts[0..($parts.length - 2)] -join "/"
    }

    # Build up the URI
    $uri = "{0}/api/v3/secrets/raw/{1}?workspaceId={2}&secretPath=%2f{3}&environment=default" -f $Server, $Name, $Project, $path

    $body = @{
        workspaceId = $Project
        secretPath = "%2f$path"
        environment = "default"
    }

    $splat = @{
        Uri = $uri
        Headers = $headers
        Method = "Get"
    }

    $data = Invoke-RestMethod @splat

    return @{$Name = $data.secret.secretValue}
}
