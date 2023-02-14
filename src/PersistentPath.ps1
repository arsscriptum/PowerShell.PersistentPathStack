
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

$Script:PathId = "PersistentPath"

function New-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('p')]
        [String]$Path
    )
    New-RegSetItem -Identifier "$Script:PathId" -String $Path
}

function Remove-PersistentPath{ 

    [CmdletBinding(SupportsShouldProcess)]
    param()
    $Path = Get-RegSetLastItem -Identifier "$Script:PathId" -Delete
    return $Path
}


function Test-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param()
    $Path = Get-RegSetLastItem -Identifier "$Script:PathId"
    return $Path
}


function Get-PersistentPathList{

    [CmdletBinding(SupportsShouldProcess)]
    param()
    $List = Get-RegSetItemList -Identifier "$Script:PathId"
    return $List
}

function Clear-PersistentPathList{

    [CmdletBinding(SupportsShouldProcess)]
    param()
    Remove-RegSetItemList -Identifier "$Script:PathId"
}


function Push-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('p')]
        [String]$Path
    )
    $ErrorOccured = $False

    $PreviousPath = (Get-Location).Path
    $ItemCount = (Get-PersistentPathList).Count

    try{
        Set-Location $Path
    }catch{
        $ErrorOccured = $True
    }

    if($ErrorOccured){
        Write-Host "Invalid Path $Path"  -f Red
    }else{
        if($ItemCount -eq 0){
            New-PersistentPath $PreviousPath  
        }        
        $FullPath = ($PWD).Path
        New-PersistentPath $FullPath  
    }
}


function Pop-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Verbose "Pop-PersistentPath"
    # Get the latest path in the stack
    $Path = Remove-PersistentPath
    if( [string]::IsNullOrEmpty($Path) ){
        Write-Verbose "Path is NULL"
        return $Null
    }
    Write-Verbose "NextPath is $Path"
    # Compare with the current path, if same, chek for the next one
    $Current = (Get-Location).Path
    
    $Peek = Test-PersistentPath
    Write-Verbose "CurrentPath is $Current, peek next in stack $Peek"
    if( ($Path -eq $Current) -and ([string]::IsNullOrEmpty($Peek) -eq $False) ){
        $Path = Remove-PersistentPath
        Write-Verbose "Remove next in stack $Path"
    }
    if( [string]::IsNullOrEmpty($Path) ){
        return $Null
    }
     Write-Verbose "Set-Location $Path"
    Set-Location $Path
}