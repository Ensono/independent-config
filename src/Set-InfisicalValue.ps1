. ./infisical/Get-Token.ps1
. ./infisical/Get-ProjectID.ps1
. ./infisical/Set-SecretFolder.ps1

function Set-InfisicalValue {

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
        # Name of the item to store
        $Name,

        [Parameter(Mandatory=$true)]
        [string]$Value
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
            Server = $InfisicalServer
            OrganisationID = $OrganisationID
            Name = $Project
            Token = $token
        }

        $Project = Get-ProjectID @splat
    }

    # Get the path off the name, this is everything before the last element
    $parts = $Name -split "/"
    $Name = $parts[-1]
    $path = ""
    if ($parts.Length -gt 1) {
        $path = $parts[0..($parts.Length - 2)] -join "/"
    }

    # Set the path of the secret
    Set-SecretFolder -InfisicalServer $InfisicalServer -Project $Project -Path $path

    # Build up the URI path
    $uri = "/api/v3/secrets/raw/{0}" -f $name

    # Set the body for the request
    $body = @{
        workspaceId = $Project
        environment = $_environment
        secretPath = "/{0}" -f $path
        secretValue = $Value
    } | ConvertTo-Json

    # Create the parameters hashtable
    $splat = @{
        Uri = "{0}{1}" -f $InfisicalServer, $uri
        Method = "Post"
        Body = $body
        Headers = $headers
    }

    # Call the endpoint to set the secret value
    Write-Information "Setting secret value: $Name"

    $response = Invoke-RestMethod @splat

    return

}
