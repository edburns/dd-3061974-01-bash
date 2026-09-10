[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, [int]::MaxValue)]
    [int]$N,

    [ValidateSet('fibonacci', 'factorial')]
    [string]$Operation = 'fibonacci'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Fibonacci {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    if ($N -lt 2) {
        return $N
    }

    [System.Numerics.BigInteger]$previous = 0
    [System.Numerics.BigInteger]$current = 1

    for ($i = 2; $i -le $N; $i++) {
        [System.Numerics.BigInteger]$next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $current
}

function Get-Factorial {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    [System.Numerics.BigInteger]$value = 1
    for ($i = 2; $i -le $N; $i++) {
        $value *= $i
    }

    return $value
}

if ($MyInvocation.InvocationName -ne '.') {
    switch ($Operation) {
        'fibonacci' {
            $value = Get-Fibonacci -N $N
            Write-Output "Fibonacci($N) = $value"
        }
        'factorial' {
            $value = Get-Factorial -N $N
            Write-Output "Factorial($N) = $value"
        }
    }
}
