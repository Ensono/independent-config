function Set-EtcdValue {
    param(
        [Parameter(Mandatory=$true)]
        [Alias("Server")]
        [string]$EtcdServer,

        [Parameter(Mandatory=$true)]
        [string]$Key,

        [Parameter(Mandatory=$true)]
        [string]$Value
    )

    # Convert the key and value to base64
    $Base64Key = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Key))
    $Base64Value = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Value))

    # Create the JSON payload
    $Payload = @{
        "key" = $Base64Key
        "value" = $Base64Value
    } | ConvertTo-Json

    # Set the headers
    $Headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "tlXjxEsDEaftvVcl.13"
    }

    # Send the request to the etcd server
    $Response = Invoke-RestMethod -Uri "$EtcdServer/v3/kv/put" -Method Post -Body $Payload -Headers $Headers

    # Return the response
    return $Response
}
