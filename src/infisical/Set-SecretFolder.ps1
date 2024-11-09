
function Set-SecretFolder() {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory=$true)]
        [Alias("Server")]
        [string]$InfisicalServer,

        [Parameter(Mandatory=$true)]
        [string]$Project,

        [string]$Path,

        [string]
        $ParentID = $null
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

    # Set the default uri for the folders
    $uri = "/api/v1/folders"

    # Get the name of the folder and the path under which it should be created
    $parts = $Path -split "/"
    $name = $parts[-1]
    if ($parts.length -gt 1) {

        $path = $parts[0..($parts.length - 2)] -join "/"
    }

    # Define the body of the request
    $body = @{
        workspaceId = $Project
        environment = $_environment
        name = $name
    }

    # add the path to the body if if one exists
    if (![string]::IsNullOrEmpty($path)) {
        $body["path"] = $path
    }

    # Set the parameters
    $splat = @{
        Uri = "{0}{1}" -f $InfisicalServer, $uri
        Method = "Post"
        Body = $body | ConvertTo-Json
        Headers = $headers
    }

    $response = Invoke-RestMethod @splat

    return $response.folder.id
=
}
