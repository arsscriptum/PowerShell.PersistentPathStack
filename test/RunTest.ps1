
$ModuleName = "PowerShell.PersistentPathStack"

try{
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "MODULE $ModuleName Import" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed    

    Import-Module $ModuleName -Verbose

}catch{
    Write-Error "$_"
}


#===============================================================================
# Dependencies
#===============================================================================




function Start-RegEditTest{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    [string]$LastKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
    [string]$LastKeyValue = "LastKey"
    [string]$Base = "HKEY_CURRENT_USER\Software\{0}\PersistentPathStack" -f "$ENV:USERNAME"
    try {
        Set-RegistryValue "$LastKeyPath" "$LastKeyValue" "$Base"      
        $RegEditExe = (Get-Command "regedit.exe").Source
        &"$RegEditExe"
        return
    }catch{
        Write-Error "$_"
    }
}


function Test-Dependencies{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "MODULE $ModuleName Test-Dependencies" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed    

    $FunctionDependencies = @( 'Clear-PersistentPaths','Get-PersistentPaths', 'New-PersistentPath', 'Pop-PersistentPath', 'Push-PersistentPath', 'Remove-PersistentPath', 'Test-PersistentPath' )

    try{
        $ScriptMyInvocation = $Script:MyInvocation.MyCommand.Path
        $CurrentScriptName = $Script:MyInvocation.MyCommand.Name
        $PSScriptRootValue = 'null' ; if($PSScriptRoot) { $PSScriptRootValue = $PSScriptRoot}
        $ModuleName = (Get-Item $PSScriptRootValue).Name

        Write-Host "[CONFIG] " -f Blue -NoNewLine
        Write-Host "CHECKING FUNCTION DEPENDENCIES..."
        $FunctionDependencies.ForEach({
            $Function=$_
            $FunctionPtr = Get-Command "$Function" -ErrorAction Ignore
            if($FunctionPtr -eq $null){
                throw "ERROR: MISSING $Function function. Please import the required dependencies"
            }else{
                Write-Host "`t`t[OK]`t" -f DarkGreen -NoNewLine
                Write-Host "$Function"
            }
        })
    }catch{
        Write-Error "$_"
    }
}




function Test-PersistentPathList{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "Test Push-PersistentPath - Adding random paths - " -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed  

    try{
        [System.Collections.ArrayList]$TestPathList = [System.Collections.ArrayList]::new()

         Write-Host "Creating Test Folders..." -f DarkYellow;

        $Null = New-Item "$PSScriptRoot\TestPath" -ItemType Directory -Force -ErrorAction Ignore
        $TestPath = (Resolve-Path "$PSScriptRoot\TestPath").Path
        Push-Location $TestPath 

        0..5 | % {
            $NewChild = "$TestPath\TEST_{0:d2}" -f $_
            $Null = New-Item "$NewChild" -ItemType Directory -Force -ErrorAction Ignore
            Push-Location $NewChild 
            [string]$Guid=(New-Guid).Guid
            $NewChild = "$NewChild\{0}" -f $Guid
            $Null = New-Item "$NewChild" -ItemType Directory -Force -ErrorAction Ignore
            Pop-Location
        }

        popd

        [System.Collections.ArrayList]$PathList = [System.Collections.ArrayList]::new()
        [System.Collections.ArrayList]$PathList = (Get-ChildItem $TestPath -Recurse -Directory).Fullname

        Write-Host "Changing Location in Test Folders Randomly..." -f DarkYellow;

        $MaxCount = $PathList.Count
        do{
         $index = Get-Random -Maximum $PathList.Count
         $p = $PathList[$index]
         $PathList.RemoveAt($index)

         Push-PersistentPath "$p"
         [void]$TestPathList.Add($p)
         $CurrentPathLog = (Get-Location).Path
         $CurrentPathLog = $CurrentPathLog.Replace("$PSScriptRoot", "")
         $CurrIndex = $MaxCount - $PathList.Count
        
         $Log = "set location to {2}. {0:d2} / {1:d2}" -f $CurrIndex , $MaxCount, "`"$CurrentPathLog`""
         Write-Host "[pushp]`t" -f Blue -NoNewLine
         Write-Host "... $Log" -f Gray

         Start-Sleep -Millisecond 100
        }
        while($PathList.Count -gt 0)

        return $TestPathList

    }catch{
        Write-Error "$_"
    }
}

try{

    Test-Dependencies

    Clear-PersistentPaths
    if((Get-PersistentPaths) -ne $Null){
        throw "PersistentPathList Should be null"
    }

    [System.Collections.ArrayList]$TestPathList = Test-PersistentPathList

    $a = Read-Host "View registry values in editor? (y/N)"
    if($a -eq 'y'){
        Start-RegEditTest
        Read-Host "press any key to continue"
    }

    $StartingPath = (Resolve-Path "$PSScriptRoot\..").Path
    [void]$TestPathList.Add($StartingPath)
    Push-PersistentPath $StartingPath


    $StackCount = (Get-PersistentPaths).Count
    $AddedCount = $TestPathList.Count

    Write-Host "===============================================================================" -f DarkRed
    Write-Host "Test Pop-PersistentPath - Moving back to previous location - " -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed 
    do{
        $Current = (Get-Location).Path
        $PathCheck = $TestPathList[$TestPathList.Count-1]
        $TestPathList.RemoveAt($TestPathList.Count-1)

        $Current = $Current.Replace("$PSScriptRoot", "")
        $PathCheck = $PathCheck.Replace("$PSScriptRoot", "")

        Write-Host "`t[ popp current ]`t" -f Yellow -NoNewLine           
        Write-Host "$Current" -f Gray;
        Write-Host "`t[popp expecting]`t" -f Blue -NoNewLine           
        Write-Host "$PathCheck" -f DarkGray;

        if($PathCheck -ne $Current){
            throw "PersistentPathList invalid, Current $Current, expecting $PathCheck "
        }
        Start-Sleep -Millisecond 100

        #Write-Host "`t`t`t`t`t=== Pop-PersistentPath ===" -f DarkGray;
        Pop-PersistentPath
        $StackCount = (Get-PersistentPaths).Count
       
    }while($TestPathList.Count -gt 0)

    Write-Host "Cleaning up..." -f DarkYellow;
    Set-Location "$PSScriptRoot"
    $Null = Remove-Item "$PSScriptRoot\TestPath" -Force -ErrorAction Ignore -Recurse

}catch{
    Write-Error "$_"
}

