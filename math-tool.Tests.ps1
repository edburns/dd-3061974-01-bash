BeforeAll {
    $script:MathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
}

Describe 'Get-Fibonacci (dot-sourced unit tests)' {
    BeforeAll {
        . $script:MathToolPath -N 0
    }

    It 'returns 0 for N=0' {
        Get-Fibonacci -N 0 | Should -Be 0
    }

    It 'returns 1 for N=1' {
        Get-Fibonacci -N 1 | Should -Be 1
    }

    It 'returns 55 for N=10 (representative value)' {
        Get-Fibonacci -N 10 | Should -Be 55
    }

    It 'produces no incidental output beyond the returned value' {
        $output = @(Get-Fibonacci -N 10 *>&1)
        $output.Count | Should -Be 1
        $output[0] | Should -Be 55
    }
}

Describe 'math-tool.ps1 (isolated CLI process tests)' {
    It 'prints exactly one result line for N=0' {
        $lines = @(& pwsh -NoLogo -NoProfile -File $script:MathToolPath -N 0)
        $lines.Count | Should -Be 1
        $lines[0] | Should -Be 'Fibonacci(0) = 0'
    }

    It 'prints exactly one result line for N=1' {
        $lines = @(& pwsh -NoLogo -NoProfile -File $script:MathToolPath -N 1)
        $lines.Count | Should -Be 1
        $lines[0] | Should -Be 'Fibonacci(1) = 1'
    }

    It 'prints exactly one result line for a representative value greater than 1' {
        $lines = @(& pwsh -NoLogo -NoProfile -File $script:MathToolPath -N 10)
        $lines.Count | Should -Be 1
        $lines[0] | Should -Be 'Fibonacci(10) = 55'
    }
}
