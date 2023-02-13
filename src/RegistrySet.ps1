
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


$Script:RegLogEnabled = $False


function Write-RegLog {

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


function Get-RegListRootPath{
    return "$ENV:OrganizationHKCU\windows.terminal\tmppaths"
}

