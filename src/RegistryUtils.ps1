


function Test-MyRegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Test-MyRegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateScript({
            $Exists = (gi $_ -ErrorAction Ignore)
            if($Exists -ne $Null){
                $type = (gi $_).PSProvider.Name
                if(($type) -ne 'Registry' ){
                    throw "`"$_`" not a registry PATH. Its a $type"
                }
            }
            return $true 
        })]     
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()]$Name
    )

    if(-not(Test-Path $Path)){
        return $false
    }
    $props = Get-ItemProperty -Path $Path -ErrorAction Ignore
    if($props -eq $Null){return $False}
    $value =  $props.$Name
    if($null -eq $value -or $value.Length -eq 0) { return $false }

    return $true
   
}



function Get-MyRegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Get-MyRegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    Get-MyRegistryValue "$ENV:OrganizationHKLM\PowershellToolsSuite\GitHubAPI" "AccessToken"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateScript({
            $Exists = (gi $_ -ErrorAction Ignore)
            if($Exists -ne $Null){
                $type = (gi $_).PSProvider.Name
                if(($type) -ne 'Registry' ){
                    throw "`"$_`" not a registry PATH. Its a $type"
                }
            }
            return $true 
        })]   
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [string]$Name
    )

    try {
        $Exists = Test-MyRegistryValue $Path $Name
        if($False -eq $Exists){ throw "no such registry entry" }

        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name)
        return $Result
    } catch {
        Write-Error "$_"
    }
}



function Set-MyRegistryValue
{
<#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-MyRegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateScript({
            $Exists = (gi $_ -ErrorAction Ignore)
            if($Exists -ne $Null){
                $type = (gi $_).PSProvider.Name
                if(($type) -ne 'Registry' ){
                    throw "`"$_`" not a registry PATH. Its a $type"
                }
            }
            return $true 
        })]    
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [String]$Name,
        [parameter(Mandatory=$true, Position=2)]
        [String]$Value,
        [Parameter(Mandatory = $false, Position=3)]
        [string]$Type='string'
           
    )

     if(-not(Test-Path $Path)){
        New-Item -Path $Path -Force  -ErrorAction ignore | Out-null
    }

    try {
        if(Test-MyRegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }else{
            throw "no such registry entry"
        }

    } catch {
        Write-Error "$_"
    }
}


function Remove-MyRegistryValue
{
<#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-MyRegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateScript({
            $Exists = (gi $_ -ErrorAction Ignore)
            if($Exists -ne $Null){
                $type = (gi $_).PSProvider.Name
                if(($type) -ne 'Registry' ){
                    throw "`"$_`" not a registry PATH. Its a $type"
                }
            }
            return $true 
        })]     
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [String]$Name
    )

 
    try {
        if(Test-MyRegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }else{
            throw "no such registry entry"
        }

    } catch {
        Write-Error "$_"
    }
}





function New-MyRegistryValue
{
<#
    .Synopsis
    Create FULL Registry Path and add value
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    New-MyRegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib" "String" -publish
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateScript({
            $Exists = (gi $_ -ErrorAction Ignore)
            if($Exists -ne $Null){
                $type = (gi $_).PSProvider.Name
                if(($type) -ne 'Registry' ){
                    throw "`"$_`" not a registry PATH. Its a $type"
                }
            }
            return $true 
        })]   
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()]$Name,
        [Parameter(Mandatory = $true, Position=2)]
        [ValidateNotNullOrEmpty()]$Value,
        [Parameter(Mandatory = $true, Position=3)]
        [ValidateNotNullOrEmpty()]$Type
    )

    try {
        if(Test-Path -Path $Path){
            if(Test-MyRegistryValue -Path $Path -Entry $Name){
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
            }
        }
        else{
            New-Item -Path $Path -Force | Out-null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type  | Out-null

    } catch {
        Write-Error "$_"
    }
}





function Find-RegSetLastIndex{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier
    )

    [string]$RegistryPath = Get-RegistrySettingsRoot

    try{
        $i = 0
        [int]$LastIndex = 0
        do{
            # generate the reg key id from identifer
            $LastIndex = $i
            [string]$NumId = "{0}_{1}" -f $Identifier, $i++

            $Value = Get-MyRegistryValue "$RegistryPath" "$NumId"
            if($Null -eq $Value){ break; }  # no more

        } while ($Value -ne $Null)
        Write-Verbose "Return $LastIndex"
        $LastIndex

    } catch {
        Write-Error "$_"
    }
   
}



function New-RegSetItem{
<#
    .Synopsis
        Add a string, to the list associated to the ID in the registry.
    .Description
        Add a string, to the list associated to the ID in the registry. Get it back with Peak-RegSetLastItem, Pop-RegSetLastItem and Get-RegSetItems
    .Parameter String
        srting
    .Parameter Id
        id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier,
        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Str','s')]
        [String]$String
    )

    [string]$RegistryPath = Get-RegistrySettingsRoot
    [string]$NumId = "{0}_{1}" -f $Identifier, (Find-RegSetNext "$Identifier")

    $null=New-MyRegistryValue "$RegistryPath" "$NumId" "$String" "string"
}


function Peak-RegSetLastItem{
<#
    .Synopsis
    Get a string, from the list associated to the ID in the registry
    .Description
    Get a string, from the list associated to the ID in the registry. You can delete it at the same time with Delete arg
    .Parameter Delete
    pop the string (del)
    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier
    )

    [string]$RegistryPath = Get-RegistrySettingsRoot

    try{
        # generate the reg key id from identifer
        [string]$NumId = "{0}_{1}" -f $Identifier, (Find-RegSetLast "$Identifier")

        # get the last value in he set
        $Value = Get-MyRegistryValue "$RegistryPath" "$NumId"

        # sanity check
        if($Null -eq $Value) { throw "no such reg key" } 
        Write-Verbose "Peak-RegSetLast $Identifier => $Value"
        
        $Value

    } catch {
        Write-Error "$_"
    }
}



function Pop-RegSetLast{
<#
    .Synopsis
    Get a string, from the list associated to the ID in the registry
    .Description
    Get a string, from the list associated to the ID in the registry. Key is deleted after

    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('Id')]
        [String]$Identifier
    )

    [string]$RegistryPath = Get-RegistrySettingsRoot

    try{
        # get the last value in the set
        [string]$Value = Peak-RegSetLast $Identifier
        # delete the registry entry
        $Null = Remove-MyRegistryValue "$RegistryPath" "$NumId"
        Write-Verbose "Pop-RegSetLast $Identifier => $Value"
        
        $Value

    } catch {
        Write-Error "$_"
    }
}



function Get-RegSetItems{
<#
    .Synopsis
        Registry set: remove all entries for an identifier
    .Description
        Find all entries in a registry string set and delete them
    .Parameter Identifier
        id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Identifier
    )
    [string]$RegistryPath = Get-RegistrySettingsRoot

    $Items = [System.Collections.ArrayList]::new()
    try{
        $i = 0
        do{
            # generate the reg key id from identifer
            [string]$NumId = "{0}_{1}" -f $Identifier, $i++

            $Value = Get-MyRegistryValue "$RegistryPath" "$NumId"
            if($Null -eq $Value){ break; }  # no more

            $Null = $Items.Add($Value)

        } while ($Value -ne $Null)
    }catch{
        Write-Error "$_"
    }

    $Items
}





function Remove-RegSetItem{
<#
    .Synopsis
        Registry set: remove an entry
    .Description
        Find an entry in the registry string set and delete it
    .Parameter Identifier
        id
    .Parameter String
        string
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i', 'Id')]
        [String]$Identifier,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$String   
    )
    try{
        [string]$RegistryPath = Get-RegistrySettingsRoot
        $ItemFound = $False
        do{
            [string]$NumId = "{0}_{1}" -f $Identifier, $i++
            $Value = Get-MyRegistryValue "$RegistryPath" "$NumId"
            if($Value -eq $String){
                $ItemFound = $True
                Write-Verbose "Remove-RegSetItem => Found Item to delete"
                $Null = Remove-MyRegistryValue "$RegistryPath" "$NumId"
            }
        }while ($Value -ne $Null)
        if($ItemFound -eq $False){ throw "failed to find item $String" }
    }catch{
        Write-Error "$_"
    }
}




function Remove-RegSetItems{
<#
    .Synopsis
        Delete all the strings, from the list associated to the ID in the registry
    .Description
        Delete all string, from the list associated to the ID in the registry.
    .Parameter Identifier
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i', 'Id')]
        [String]$Identifier     
    )
    try{
        $i = 0
        do{
            # generate the reg key id from identifer
            [string]$NumId = "{0}_{1}" -f $Identifier, $i++

            $Value = Get-MyRegistryValue "$RegistryPath" "$NumId"
            if($Null -eq $Value){ break; }  # no more

            $Null = Remove-MyRegistryValue "$RegistryPath" "$NumId"

        } while ($Value -ne $Null)
    }catch{
        Write-Error "$_"
    }
}