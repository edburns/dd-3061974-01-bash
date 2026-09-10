Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'Get-Fibonacci unit behavior' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $dotSourceOutput = . $scriptPath -N 0
    }

    It 'does not emit output when dot-sourced' {
        $dotSourceOutput | Should -BeNullOrEmpty
    }

    It 'returns 0 for N=0' {
        Get-Fibonacci -N 0 | Should -Be 0
    }

    It 'returns 1 for N=1' {
        Get-Fibonacci -N 1 | Should -Be 1
    }

    It 'returns 5 for N=5' {
        Get-Fibonacci -N 5 | Should -Be 5
    }

    It 'returns the exact value for N=100' {
        Get-Fibonacci -N 100 | Should -Be ([System.Numerics.BigInteger]::Parse('354224848179261915075'))
    }

    It 'rejects negative input' {
        { Get-Fibonacci -N -1 } | Should -Throw
    }
}

Describe 'math-tool CLI behavior' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
        $invokeChildPwsh = {
            param(
                [Parameter(Mandatory = $true)]
                [string[]]$Arguments
            )

            $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
            $startInfo.FileName = 'pwsh'
            $startInfo.UseShellExecute = $false
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            foreach ($argument in $Arguments) {
                $startInfo.ArgumentList.Add($argument)
            }

            $process = [System.Diagnostics.Process]::new()
            $process.StartInfo = $startInfo
            try {
                $process.Start() | Out-Null
                $stdOut = $process.StandardOutput.ReadToEnd()
                $stdErr = $process.StandardError.ReadToEnd()
                $process.WaitForExit()

                [PSCustomObject]@{
                    ExitCode = $process.ExitCode
                    StdOut   = @($stdOut -split '\r?\n' | Where-Object { $_ -ne '' })
                    StdErr   = $stdErr
                }
            }
            finally {
                $process.Dispose()
            }
        }
    }

    It 'prints exactly one line for N=0' {
        $result = & $invokeChildPwsh -Arguments @('-NoLogo', '-NoProfile', '-File', $scriptPath, '-N', '0')

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -BeNullOrEmpty
        $result.StdOut.Count | Should -Be 1
        $result.StdOut[0] | Should -Be 'Fibonacci(0) = 0'
    }

    It 'prints exactly one line for N=1' {
        $result = & $invokeChildPwsh -Arguments @('-NoLogo', '-NoProfile', '-File', $scriptPath, '-N', '1')

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -BeNullOrEmpty
        $result.StdOut.Count | Should -Be 1
        $result.StdOut[0] | Should -Be 'Fibonacci(1) = 1'
    }

    It 'prints exactly one line for N=5' {
        $result = & $invokeChildPwsh -Arguments @('-NoLogo', '-NoProfile', '-File', $scriptPath, '-N', '5')

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -BeNullOrEmpty
        $result.StdOut.Count | Should -Be 1
        $result.StdOut[0] | Should -Be 'Fibonacci(5) = 5'
    }

    It 'rejects negative input and does not print success-shaped output' {
        $result = & $invokeChildPwsh -Arguments @('-NoLogo', '-NoProfile', '-File', $scriptPath, '-N', '-1')

        $result.ExitCode | Should -Not -Be 0
        $result.StdOut.Count | Should -BeLessOrEqual 1
        if ($result.StdOut.Count -eq 1) {
            $result.StdOut[0] | Should -Not -Match '^Fibonacci\(-1\) ='
        }
    }
}
