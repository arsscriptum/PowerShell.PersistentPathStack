
<#
Test-RegistryValue
Get-RegistryValue
Set-RegistryValue
Remove-RegistryValue
New-RegistryValue

Find-RegSetLastIndex
New-RegSetItem
Peak-RegSetLastItem
Pop-RegSetLast
Get-RegSetItems
Remove-RegSetItem
Remove-RegSetItems
#>

# Set script preferences.

. "$PSScriptRoot/Assert.ps1"


$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# Results object to pass to jobs.

$results = @{
  totalCount = 0;
  passedCount = 0;
  passedTests = @();
  failedTests = @();
  times = @{};
  startTime = Get-Date;
}

function Run-TestProtectedAsJob
{
  param($script, $testName)

  $job = Start-Job -Name $testName -ScriptBlock { 
    param($script, $testName, $results, $dir)

    $VerbosePreference = "SilentlyContinue"
    $ErrorActionPreference = "Stop"

    function Run-ScriptTest{
        [CmdletBinding(SupportsShouldProcess)]
        param($script, $testName, $results)

        $testStart = Get-Date
        try {
            Write-Host  -ForegroundColor Green =====================================
            Write-Host  -ForegroundColor Green "Running test $testName"
            Write-Host  -ForegroundColor Green =====================================
            Write-Host
            & $script > $null
            $results.passedCount = $results.passedCount + 1
            Write-Host
            Write-Host -ForegroundColor Green =====================================
            Write-Host -ForegroundColor Green "Test Passed"
            Write-Host -ForegroundColor Green =====================================
            Write-Host
            $results.passedTests += $testName
        }catch{
            Out-String -InputObject $_.Exception | Write-Host -ForegroundColor Red
            Write-Host
            Write-Host -ForegroundColor Red =====================================
            Write-Host -ForegroundColor Red "Test Failed"
            Write-Host -ForegroundColor Red =====================================
            Write-Host
            $results.failedTests += $testName
        }finally{
            $testEnd = Get-Date
            $testElapsed = $testEnd - $testStart
            $results.times[$testName] = $testElapsed
            $results.totalCount = $results.totalCount + 1
        }

        return $results
    }

    # Test helpers.
    . "$dir/Assert.ps1"
    . "$dir/Test-RegistryFunctions.ps1"


    $block = [Scriptblock]::Create($script)

    return Run-ScriptTest $block $testName $results
  } -ArgumentList ($script, $testName, $results, $pwd)

  return $job
}


$jobs = @(

  #Proflie tests.
  (Run-TestProtectedAsJob { Test-RegistryFunctions } "Test-RegistryFunctions1")
  (Run-TestProtectedAsJob { Test-RegistryFunctions } "Test-RegistryFunctions2")


)

# Wait for all of the jobs we just created (and report progress).

while (($jobs | Where-Object { $_.State -eq "Running" }).Count -gt 0) {
  $running = @($jobs | Where-Object { $_.State -eq "Running" } | Select-Object -ExpandProperty Name)
  $completed = @($jobs | Where-Object { $_.State -eq "Completed" } | Select-Object -ExpandProperty Name)
  $runningString = $running -join ", "
  $completedString = $completed -join ", "

  Write-Progress -Activity "Netcore Tests" -CurrentOperation "Running: $runningString" -Status "Completed: $completedString" -PercentComplete ($completed.Count * 100.0 / $jobs.Count)

  Start-Sleep 5
}

# Receive the jobs and compile data.
$AllJobsList = Get-Job
$AllJobsList | % { Wait-Job $_ }
$jobs
return $jobs
$jobs | % {
  $results.passedTests += $_.passedTests
  $results.passedCount += $_.passedCount
  $results.totalCount += $_.totalCount
  $results.failedTests += $_.failedTests
  $results.times += $_.times
}

# Write results.

Write-Host
Write-Host -ForegroundColor Green "${$results.passedCount} / ${$results.totalCount} E2E Scenario Tests Pass"
Write-Host -ForegroundColor Green "============"
Write-Host -ForegroundColor Green "PASSED TESTS"
Write-Host -ForegroundColor Green "============"
$results.passedTests | ForEach-Object { Write-Host -ForegroundColor Green "PASSED "$_": "($results.times[$_]).ToString()}
Write-Host -ForegroundColor Green "============"
Write-Host
if ($results.failedTests.Count -gt 0)
{
  Write-Host -ForegroundColor Red "============"
  Write-Host -ForegroundColor Red "FAILED TESTS"
  Write-Host -ForegroundColor Red "============"
  $results.failedTests | ForEach-Object { Write-Host -ForegroundColor Red "FAILED "$_": "($results.times[$_]).ToString()}
  Write-Host -ForegroundColor Red "============"
  Write-Host
}
$results.endTime = Get-Date
Write-Host -ForegroundColor Green "======="
Write-Host -ForegroundColor Green "TIMES"
Write-Host -ForegroundColor Green "======="
Write-Host
Write-Host -ForegroundColor Green "Start Time: $($results.startTime)"
Write-Host -ForegroundColor Green "End Time: $($results.endTime)"
Write-Host -ForegroundColor Green "Elapsed: "($results.endTime - $results.startTime).ToString()
Write-Host -ForegroundColor Black "============================================================================================="
Write-Host
Write-Host

$ErrorActionPreference = "Continue"