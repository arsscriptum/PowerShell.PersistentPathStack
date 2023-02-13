
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


$Script:RegLogEnabled = $False


function Write-RegLog {    ## NOEXPORT

    <#
    .SYNOPSIS
        Copy one or 2 files to a destination folder
    .DESCRIPTION
        Copy one or 2 files to a destination folder 
            - if file size is less than pre-defined value (Threshold) 
            - after asking the user for copy confirmation   
       
    .PARAMETER Message (-m)
        Log Message
    .PARAMETER Type 'wrn','nrm','err','don'
        Message Type
            'wrn' : Warning
            'nrm' : Normal
            'err' : Error
            'don' : Done

    .EXAMPLE 
        log "Copied $Src to $Dst" -t 'don'  
        log "$Src ==> $Destination" -t 'wrn'
        log "test error" -t 'err'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('m')]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [ValidateSet('wrn','nrm','err','don')]
        [String]$Type='nrm',
        [Parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NoReturn
    )

    if($Script:RegLogEnabled -eq $False){return}
    if( ($PSBoundParameters.ContainsKey('Verbose')) -Or ( $Script:LogVerbose )  ){
        Write-Verbose "$Message"
        return
    }
    switch ($Type) {
        'nrm'  {
            Write-Host -n -f DarkCyan "[REG] " ; if($NoReturn) { Write-Host -n -f DarkGray "$Message"} else {Write-Host -f DarkGray "$Message"}
        }
        'don'  {
            Write-Host -n -f DarkGreen "[DONE] " ; Write-Host -f DarkGray "$Message"  
        }
        'wrn'  {
            Write-Host -n -f DarkYellow "[WARN] " ; Write-Host -f White "$Message" 
        }
        'err'  {
            Write-Host -n -f DarkRed "[ERROR] " ; Write-Host -f DarkYellow "$Message" 
        }
    }
}

New-Alias -Name 'log' -Value 'Write-RegLog' -ErrorAction Ignore -Force


function Get-RegSetRootPath{     ## NOEXPORT
    $Base = "HKCU:\Software\{0}\PersistentPathStack" -f "$ENV:USERNAME"
    if( -not ( Test-Path $Base ) ){
        New-Item -Path $Base -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    return "$Base"
}

function Get-LastIndexForId{   ## NOEXPORT

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )

    $Script:RegistryPath = Get-RegSetRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $LastId = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

        if($Found -eq $False){ return $LastId }
        $LastId = $num
        $num++
        
    }
    log "Return $LastId"
    return $LastId
}

function Get-NextIndexForId{   ## NOEXPORT

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Id
    )
    $Script:RegistryPath = Get-RegSetRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Items = 0
    $num = 0
    $Found = $True
    While( $Found ){
        $NumId = $Id + "_$num"

        $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"
        if($Found -eq $True){ $Items++ }
        $num++
        
    }
    $Ret = $Items 
    log "Return $Ret"
    return $Ret
}

function New-RegSetItem{   ## NOEXPORT
<#
    .Synopsis
    Add a string, to the list associated to the ID in the registry.
    .Description
    Add a string, to the list associated to the ID in the registry. Get it back with Get-RegSetLastItem and Get-RegSetItemList
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

    $Script:RegistryPath = Get-RegSetRootPath

    $i = Get-NextIndexForId "$Identifier"
    log "Get-NextIndexForId `"$Identifier`" ==> $i "
    
    $NumId = $Identifier + "_$i"

    
    log "New-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
    $null=New-RegistryValue "$Script:RegistryPath" "$NumId" "$String" "string"


    
}


function Get-RegSetLastItem{   ## NOEXPORT
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
        [String]$Identifier,
        [Parameter(Mandatory=$false)]
        [Alias('d','Del')]
        [switch]$Delete
    )

    $Script:RegistryPath = Get-RegSetRootPath

    try{

        if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
        $i = Get-LastIndexForId "$Identifier"
        log "Get-LastIndexForId `"$Identifier`" ==> $i "
        
        $NumId = $Identifier + "_$i"

        
        log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`" `"$String`" `"string`""
        $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

        if($Exists){
            $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
            if($Delete){
                log "Delete Key..."
                $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
            }
            return $Value
        }else{
            throw "Key doesn't exists"
        }      
    }catch{
        log "$_" -t 'err'
    }

    
}


function Get-RegSetItemList{   ## NOEXPORT
<#
    .Synopsis
    Get all the strings, from the list associated to the ID in the registry
    .Description
    Get all string, from the list associated to the ID in the registry.
    .Parameter Id
    id
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('i')]
        [String]$Identifier
    )
    $Script:RegistryPath = Get-RegSetRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Identifier + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
            log "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($Found -eq $True){  

                $Exists=Test-RegistryValue "$Script:RegistryPath" "$NumId"

                if($Exists){
                    $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
                    $Null = $Ret.Add($Value)
                }else{
                    break;
                }
                $num++ 
            }    
        } 
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}



function Remove-RegSetItemString{   ## NOEXPORT
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
        [String]$Identifier,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$String,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="test only")]
        [switch]$Test        
    )
     $TestMode = $False
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Verbose "Verbose OUTPUT"             
    }
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Verbose "TEST ONLY"             
        $TestMode = $True
    }
    $Script:RegistryPath = Get-RegSetRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Identifier + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
             Write-Verbose "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            $Value = Get-RegistryValue "$Script:RegistryPath" "$NumId"
            if($TestMode -eq $false){  
                if($Value -eq $String){
                    $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
                    Write-Verbose "Remove-RegistryValue `"$Script:RegistryPath`" `"$NumId`""
                }
            }else{
                log "TestMode : would delete `"$Script:RegistryPath`" `"$NumId`" "

                break;
            }
        $num++ 
        }     
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}




function Remove-RegSetItemList{   ## NOEXPORT
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
        [String]$Identifier,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="test only")]
        [switch]$Test        
    )
     $TestMode = $False
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Verbose "Verbose OUTPUT"             
    }
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Verbose "TEST ONLY"             
        $TestMode = $True
    }
    $Script:RegistryPath = Get-RegSetRootPath

    if ($PSBoundParameters.ContainsKey('Verbose')) { $Global:LogVerbose = $True }
    $Ret = [System.Collections.ArrayList]::new()
    try{
        $LastId = 0
        $num = 0
        $Found = $True
        While( $Found ){
            $NumId = $Identifier + "_$num"

            $Found = Test-RegistryValue "$Script:RegistryPath" "$NumId"
             Write-Verbose "Test-RegistryValue `"$Script:RegistryPath`" `"$NumId`"  ==> Found $Found"

            if($TestMode -eq $false){  
                $Null = Remove-RegistryValue "$Script:RegistryPath" "$NumId"
                 Write-Verbose "Remove-RegistryValue `"$Script:RegistryPath`" `"$NumId`""
            }else{
                log "TestMode : would delete `"$Script:RegistryPath`" `"$NumId`" "

                break;
            }
        $num++ 
        }     
    }catch{
        log "$_" -t 'err'
    }

    return $Ret
    
}

