
# Import the necesssary files
. "$PSScriptRoot\Get-EtcdValue.ps1"
. "$PSScriptRoot\Set-EtcdValue.ps1"
. "$PSScriptRoot\Get-InfisicalValue.ps1"

function Get-ConfigItem() {

    [CmdletBinding()]
    param (

        [string]
        # Server to use to get the information
        $Server = $env:CONFIG_SERVER,

        [Parameter(Mandatory = $true)]
        [string]
        # This is the path to the item in the configuration system
        $Path,

        [switch]
        # State that Etcd should be used
        $Etcd,

        [switch]
        # State that Infisical shhould be used
        $Infisical,

        [ValidatePattern("ado|raw|yaml|.+?(?=,|$)|json|kv")]
        [string]
        # Format of the output data
        $Format = "raw",

        [string[]]
        # Otions that can be passed, such as the ability to change the case
        # of the key, or turn the valus that contain a comma into an array
        $Options = @(),

        [string]
        $Project

    )

    if ([string]::IsNullOrEmpty($Server)) {
        throw "Server is required"
    }

    # Throw an error if both Etcd and Infisical are used
    if ($Etcd.IsPresent -and $Infisical.IsPresent) {
        throw "Both Etcd and Infisical cannot be used at the same time"
    }

    # If Etcd is used, get the value from Etcd
    if ($Etcd.IsPresent) {
        $items = Get-EtcdValue -Server $Server -Prefix $Path
    }

    # If Infisical is used, get the value from Infisical
    if ($Infisical.IsPresent) {
        $items = Get-InfisicalValue -Server $Server -Project $Project -Name $Path
    }


    # iterate around the keys in the items
    $data = @()
    foreach ($key in $items.Keys) {

        # set the key to the correct case based on the options
        if ($options -contains "upper") {
            $key = $key.ToUpper()
        }
        if ($options -contains "lower") {
            $key = $key.ToLower()
        }

        # split the value based on the options
        if ($options -contains "split") {
            $items[$key] = $items[$key] -split ","
        }

        # based on the format, output the appropriate data
        switch -wildcard ($Format) {
            "ado" {
                $data += "##vso[task.setvariable variable={0}]{1}" -f $key, $items[$key]
            }
            "kv" {
                $data += "{0}=`"{1}`"" -f $key, $items[$key]
            }
            "env*" {

                $prefix = ""

                # Determine if a prefix has been set
                $prefix = $Format.split(":")[-1]

                # Set the name of the environment variable
                $name = "{0}{1}" -f $prefix, $key

                Write-Host "Setting Environment variable: $name"

                # Set the environment variable in the shell
                $path = "env:\{0}" -f $name
                Set-Item -Path $path -Value $items[$key]
            }
        }
    }

    # switch on the format parameter
    switch ($Format) {
        "raw" {
            $data = $items
        }
        "json" {
            $data = $items | ConvertTo-Json
        }
        "yaml" {
            $data = $items | ConvertTo-Yaml
        }
    }

    # Output the data that has been set
    Write-Output $data
}
