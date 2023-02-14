
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
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"
    )

    New-RegSetStack $StackName
    $PathId = "PersistentPath_{0}" -f $StackName
    New-RegSetItem -Identifier "$PathId" -String $Path
}

function Remove-PersistentPath{ 

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"
    )
    $PathId = "PersistentPath_{0}" -f $StackName
    $Path = Get-RegSetLastItem -Identifier "$PathId" -Delete
    return $Path
}


function Test-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"
    )
    $PathId = "PersistentPath_{0}" -f $StackName
    $Path = Get-RegSetLastItem -Identifier "$PathId"
    return $Path
}


function Get-PersistentPaths{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default",
        [Parameter(Mandatory=$false)]
        [switch]$Stacks,
        [Parameter(Mandatory=$false)]
        [switch]$All

    )
    if($Stacks){
        Clear-PersistentPathStacks

        return Get-RegSetStacks
    }    
    if($All){
        Clear-PersistentPathStacks

        $Ret = [System.Collections.ArrayList]::new()
        Write-Verbose "Getting all stacks"
        $StackList = Get-RegSetStacks
        ForEach($sid in $StackList){
             Write-Verbose "StackList $sid"
            
            $PathId = "PersistentPath_{0}" -f $sid

            $List = Get-RegSetItemList -Identifier "$PathId"
            $ListCount = $List.Count
            Write-Verbose "Get-RegSetItemList $PathId ListCount $ListCount"
            ForEach($item in $List){
                Write-Verbose "$sid => $item"
                

                $o = [PscustomObject]@{
                    Path = $item
                    Stack = $sid
                }
                [void]$Ret.Add($o)
            }
            
        }
        return $Ret
    }
    $PathId = "PersistentPath_{0}" -f $StackName
    $List = Get-RegSetItemList -Identifier "$PathId"
    return $List
}

function Clear-PersistentPaths{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"
    )
    $PathId = "PersistentPath_{0}" -f $StackName
    Remove-RegSetItemList -Identifier "$PathId"
}


function Push-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('p')]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"        
    )
    $ErrorOccured = $False

    $PreviousPath = (Get-Location).Path
    $ItemCount = (Get-PersistentPaths -StackName $StackName).Count

    try{
        Set-Location $Path
    }catch{
        $ErrorOccured = $True
    }

    if($ErrorOccured){
        Write-Host "Invalid Path $Path"  -f Red
    }else{
        if($ItemCount -eq 0){
            New-PersistentPath $PreviousPath -StackName $StackName
        }        
        $FullPath = ($PWD).Path
        New-PersistentPath $FullPath -StackName $StackName
    }
}


function Pop-PersistentPath{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [String]$StackName="default"        
    )
    Write-Verbose "Pop-PersistentPath"
    # Get the latest path in the stack
    $Path = Remove-PersistentPath -StackName $StackName
    if( [string]::IsNullOrEmpty($Path) ){
        Write-Verbose "Path is NULL"
        return $Null
    }
    Write-Verbose "NextPath is $Path"
    # Compare with the current path, if same, chek for the next one
    $Current = (Get-Location).Path
    
    $Peek = Test-PersistentPath -StackName $StackName
    Write-Verbose "CurrentPath is $Current, peek next in stack $Peek"
    if( ($Path -eq $Current) -and ([string]::IsNullOrEmpty($Peek) -eq $False) ){
        $Path = Remove-PersistentPath -StackName $StackName
        Write-Verbose "Remove next in stack $Path"
    }
    if( [string]::IsNullOrEmpty($Path) ){
        return $Null
    }
     Write-Verbose "Set-Location $Path"
    Set-Location $Path
}
