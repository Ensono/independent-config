# Import the necesssary files
. "$PSScriptRoot\Get-EtcdValue.ps1"
. "$PSScriptRoot\Set-EtcdValue.ps1"
. "$PSScriptRoot\Set-InfisicalValue.ps1"
. "$PSScriptRoot\Get-InfisicalValue.ps1"

function Set-ConfigItem() {

    [CmdletBinding()]
    param (

        [string]
        # Server to use to get the information
        $Server = $env:CONFIG_SERVER,

        [Parameter(Mandatory = $true)]
        [string]
        # Project from which the values pertain to
        $Project,

        [Parameter(Mandatory = $true)]
        [string]
        # The environment for which the values apply
        $Environment,

        [Parameter(ValueFromPipeline = $true)]
        [string]
        # Values that should be set
        # Can be a list of key value pairs, a JSON or YAML file
        $Values,

        [switch]
        # State that Etcd should be used
        $Etcd,

        [switch]
        # State that Infisical shhould be used
        $Infisical,

        [string]
        # Set the flavour of the values, e.g. if it is terraform data
        $Flavour

    )

    # Determine if the values is the path to a file, and if so read it
    if (Test-Path $Values) {
        Write-Host "Reading values from file: $Values"
        $Values = Get-Content $Values
    }

    # Attempt the read the data in as JSON, YAML of KV pairs
    try {
        Write-Host "Attempting to convert data from: JSON"
        $data = $Values | ConvertFrom-Json

    } catch {
        # If it fails, attempt to read the data in as YAML
        try {

            # If it fails, attempt to read the data in as a list of key value pairs
            Write-Host "Attempting to convert data from: KV Pairs"
            $data = $Values | ConvertFrom-StringData -Delimiter "="
        } catch {
            Write-Host "Attempting to convert data from: YAML"
            $data = $Values | ConvertFrom-Yaml
        }
    }

    # Check the flavour of the data, if it is terraform then convert to a hashtable of the name
    # and the value
    if (![string]::IsNullOrEmpty($Flavour)) {

        switch ($Flavour) {
            "terraform" {

                $new_data = @{}
                foreach ($key in $data.psobject.properties.name) {

                    $new_data[$key] = $data.$key.value
                }

                $data = $new_data

            }
        }
    }

    # Iterate over the data and set the values in the configuration store
    foreach ($key in $data.Keys) {
        $value = $data[$key]

        # If Etcd is used, set the value in Etcd
        if ($Etcd.IsPresent) {

            # determine the key to set in the configuration store
            $key_path = "{0}/{1}/{2}" -f $Project, $Environment, $key
            Write-Host "Setting value in Etcd: $key_path [$value]"

            Set-EtcdValue -Server $Server -Key "$Project/$Environment/$key" -Value $value
        }

        # If Infisical is used, set the value in Infisical
        if ($Infisical.IsPresent) {

            # determine the key to set in the configuration store
            $key_path = "{0}/{1}/{2}" -f $Project, $Environment, $key
            Write-Host "Setting value in Infisical: $key_path [$value]"

            Set-InfisicalValue -Server $Server -Project $Project -Name "$Environment/$key" -Value $value
        }
    }


}
