
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


function Peek-PersistentPath{

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



function Push-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('p')]
        [String]$Path
    )
    $ErrorOccured = $False
    try{
        Set-Location $Path
    }catch{
        $ErrorOccured = $True
    }

    if($ErrorOccured){
        Write-Host "Invalid Path $Path"  -f Red
    }else{
        $FullPath = ($PWD).Path
        New-PersistentPath $FullPath  
    }
}


function Pop-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $Path = Remove-PersistentPath
    $Valid = ( [string]::IsNullOrEmpty( $Path ) -eq $False )
    if($Valid){
        Set-Location $Path
    }
}