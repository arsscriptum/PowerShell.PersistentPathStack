


function Get-PersistentPathModuleInformation{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try{
        $ModuleName = $ExecutionContext.SessionState.Module
        
        $ModuleScriptPath = $ScriptMyInvocation = $Script:MyInvocation.MyCommand.Path
        $ModuleScriptPath = (Get-Item "$ModuleScriptPath").DirectoryName
        $CurrentScriptName = $Script:MyInvocation.MyCommand.Name
        if([string]::IsNullOrEmpty($ModuleName)){ throw "not in module" }
    }catch{
        Write-Warning "$_"
        if([string]::IsNullOrEmpty($ModuleName)){
            $i = $ModuleScriptPath.LastIndexOf('\') + 1
            [string]$ModuleName = $ModuleScriptPath.SubString($i)
        }
    }
    $ModuleInformation = @{
        Module        = $ModuleName
        ModuleScriptPath  = $ModuleScriptPath
        CurrentScriptName = $CurrentScriptName
    }
    Write-Verbose "ModuleInformation => $ModuleName, $ModuleScriptPath"
    $ModuleInformation
}

function Get-RegistrySettingsRoot{
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
    [string]$ModuleName = (Get-PersistentPathModuleInformation).Module
    Write-Verbose "Detected ModuleName $ModuleName"
    [string]$RegistryRoot = "HKCU:\Software\{0}\{1}\Paths" -f $Username, $ModuleName
    
    if(-not(Test-Path -Path "$RegistryRoot")){
        Write-Verbose "Creating $RegistryRoot"
        New-Item -Path "$RegistryRoot" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }

    Write-Verbose "RegistrySettingsRoot => $RegistryRoot"
    $RegistryRoot
}
