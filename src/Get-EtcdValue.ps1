function Get-EtcdValue {
    param(
        [Parameter(Mandatory=$true)]
        [Alias("Server")]
        [string]$EtcdServer,

        [Parameter(Mandatory=$true)]
        [string]$Prefix
    )

    # Convert the prefix to base64
    $Base64Prefix = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Prefix))

    # Calculate the end key by incrementing the last byte of the prefix
    $EndKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Prefix)
    $EndKeyBytes[$EndKeyBytes.Length - 1]++
    $Base64EndKey = [System.Convert]::ToBase64String($EndKeyBytes)

    # Create JSON payload
    $Payload = @{
        "key" = $Base64Prefix
        "range_end" = $Base64EndKey
    } | ConvertTo-Json

    # Set the headers
    $Headers = @{
        "Content-Type" = "application/json"
    }

    $Values = @{}

    # Send the request to the etcd server
    $Response = Invoke-RestMethod -Uri "$EtcdServer/v3/kv/range" -Method Post -Body $Payload -Headers $Headers

    # check the count value, if it is one, then return the value
    $Response.kvs | ForEach-Object {

        $key = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.key))
        $value = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.value))

        # Get the last item in the specified path as the key
        $key = $key.Split("/")[-1]

        $Values[$key] = $value
    }

    # Return the values
    return $Values
}
