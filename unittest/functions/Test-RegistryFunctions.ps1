
. "$PSScriptRoot/src/RegistryUtils.ps1"
. "$PSScriptRoot/src/Helpers.ps1"

function Get-UnitTestRegistryPath{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    [string]$Username = "$ENV:USERNAME"
    if([string]::IsNullOrEmpty($Username)){
        Write-Verbose "ENV:USERNAME invalid, check for ENV:HOMEPATH"
        $i = $ENV:HOMEPATH.LastIndexOf('\') + 1
        [string]$Username = $ENV:HOMEPATH.SubString($i)
        if([string]::IsNullOrEmpty($Username)){ 
            Write-Warning "could not retrieve username, placeholder used" 
            [string]$Username = "powershell_user"
        }
    }

    [string]$RegistryRoot = "HKCU:\Software\{0}\UnitTest" -f $Username
    
    Remove-Item -Path "$RegistryRoot" -Recurse -Force -ErrorAction Ignore | Out-Null
    New-Item -Path "$RegistryRoot" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    
    $RegistryRoot
}


function Test-RegistryFunctions{

    [string]$KeyPath = Get-UnitTestRegistryPath
    [string]$KeyName = (New-Guid).Guid
    [string]$KeyValue = (New-Guid).Guid

    $exists = Test-MyRegistryValue $KeyPath $KeyName

    Assert-True { $exists -eq $False }
    #New-MyRegistryValue $KeyPath $KeyName $KeyValue "String"

    #Assert-AreEqual $asets $null;
}

Test-RegistryFunctions