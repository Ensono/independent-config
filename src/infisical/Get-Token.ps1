
function Get-Token() {

    [CmdletBinding()]
    param (

        [string]
        # Server to authenticate against
        $Server = $env:CONFIG_SERVER,

        [string]
        # Client ID to use
        $ClientID = $env:INFISICAL_CLIENT_ID,

        [string]
        # Client Secret associated with the ID
        $ClientSecret = $env:INFISICAL_CLIENT_SECRET
    )

    # Configure the headers for the request
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = ("Bearer {0}" -f $ApiToken)
    }

    # Build up the URI path to call
    $uri = "/api/v1/auth/universal-auth/login"

    # Set the body for the request
    $body = @{
        clientId = $ClientID
        clientSecret = $ClientSecret
    } | ConvertTo-Json

    # Call the endpoint to the token
    $response = Invoke-RestMethod -Uri "$Server/$uri" -Method Post -Body $body -Headers $headers

    $response.accessToken
}
