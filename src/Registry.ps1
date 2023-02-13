
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function Publish-RegistryChanges   ## NOEXPORT
{

    <#
    .SYNOPSIS
        Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!
    .DESCRIPTION
        Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!
        
    .PARAMETER Timeout 
       Timeout
    .PARAMETER Flags
        SMTO_ABORTIFHUNG 0x0002
        The function returns without waiting for the time-out period to elapse if the receiving thread appears to not respond or "hangs."
        SMTO_BLOCK 0x0001
        Prevents the calling thread from processing any other requests until the function returns.
        SMTO_NORMAL0x0000
        The calling thread is not prevented from processing other requests while waiting for the function to return.
        SMTO_NOTIMEOUTIFNOTHUNG 0x0008
        The function does not enforce the time-out period as long as the receiving thread is processing messages.
        SMTO_ERRORONEXIT 0x0020
        The function should return 0 if the receiving window is destroyed or its owning thread dies while the message is being processed.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false, Position=0)]
        [int]$Timeout = 1000,
        [Parameter(Mandatory = $false, Position=1)]
        [int]$Flags = 2 # SMTO_ABORTIFHUNG: return if receiving thread does not respond (hangs)
    )
    $TypeAdded = $True
    try{
        [WinAPI.RegAnnounce]$test
    }catch{
        $TypeAdded = $False
        Write-Verbose "WinAPI.RegAnnounce not declared..."
    }
    $Result = $true
    $funcDef = @'

        [DllImport("user32.dll", SetLastError = true, CharSet=CharSet.Auto)]

         public static extern IntPtr SendMessageTimeout (
            IntPtr     hWnd,
            uint       msg,
            UIntPtr    wParam,
            string     lParam,
            uint       fuFlags,
            uint       uTimeout,
        out UIntPtr    lpdwResult
         );

'@

    if($TypeAdded -eq $False){
         Write-Verbose "ADDING WinAPI.RegAnnounce"
        $funcRef = add-type -namespace WinAPI -name RegAnnounce -memberDefinition $funcDef
    }
    
    try{
        $HWND_BROADCAST   = [intPtr] 0xFFFF
        $WM_SETTINGCHANGE =          0x001A  # Same as WM_WININICHANGE
        $fuFlags          =               $Flags  
        $timeOutMs        =            $Timeout  # Timeout in milli seconds
        $res              = [uIntPtr]::zero

        # If the function succeeds, this value is non-zero.
        $funcVal = [WinAPI.RegAnnounce]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::zero, "Environment", $fuFlags, $timeOutMs, [ref] $res);

        if ($funcVal -eq 0) {
           throw "SendMessageTimeout did not succeed, res= $res"
        }
        else {
           write-Verbose "Message sent"
           return $True
        }
    }
    catch{
        $Result = $False
        Write-Error $_
    }
    return $Result
}




function Test-RegistryValue   ## NOEXPORT
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
    Test-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
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



function Get-RegistryValue   ## NOEXPORT
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
    Get-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    Get-RegistryValue "$ENV:OrganizationHKLM\PowershellToolsSuite\GitHubAPI" "AccessToken"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [string]$Name
    )

    if(-not(Test-RegistryValue $Path $Name)){
        return $null
    }
    try {
        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name)
        return $Result
    }

    catch {
        return $null
    }
   
}




function Set-RegistryValue   ## NOEXPORT
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
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [String]$Name,
        [parameter(Mandatory=$true, Position=2)]
        [String]$Value,
        [Parameter(Mandatory = $false, Position=3)]
        [string]$Type='string',
        [Parameter(Mandatory = $false)]
        [switch]$Publish
           
    )

     if(-not(Test-Path $Path)){
        New-Item -Path $Path -Force  -ErrorAction ignore | Out-null
    }

    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
      
        $Result = $True
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-null
        if($Publish){$Result = Publish-RegistryChanges}
        return $Result
    }

    catch {
        return $false
    }
}



function Remove-RegistryValue   ## NOEXPORT
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
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory = $true, Position=1)]
        [Alias('Entry')]
        [String]$Name,
        [Parameter(Mandatory = $false)]
        [switch]$Publish
    )

 
    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
        $Result = $True
        if($Publish){$Result = Publish-RegistryChanges}
        return $Result
    }

    catch {
        return $false
    }
}




function New-RegistryValue   ## NOEXPORT
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
    New-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib" "String" -publish
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [Parameter(Mandatory = $true, Position=0)]
     [ValidateNotNullOrEmpty()]$Path,
     [Parameter(Mandatory = $true, Position=1)]
     [Alias('Entry')]
     [ValidateNotNullOrEmpty()]$Name,
     [Parameter(Mandatory = $true, Position=2)]
     [ValidateNotNullOrEmpty()]$Value,
     [Parameter(Mandatory = $true, Position=3)]
     [ValidateNotNullOrEmpty()]$Type,
     [Parameter(Mandatory = $false)]
     [switch]$Publish
    )

    try {
        if(Test-Path -Path $Path){
            if(Test-RegistryValue -Path $Path -Entry $Name){
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
            }
        }
        else{
            New-Item -Path $Path -Force | Out-null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type  | Out-null
        $Result = $True
        if($Publish){$Result = Publish-RegistryChanges}
        return $Result
    }

    catch {
        return $false
    }
   
}

