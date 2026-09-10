## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `6-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

The resolved acceptance decision is that the canonical command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner; do not replace, bypass, or weaken either.

The resolved behavior contract is that direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`, while functions return only the numeric value with no incidental output. Inputs are non-negative integers. The production and test files are the repository-root `math-tool.ps1` and `math-tool.Tests.ps1`.

There are no spike implementations to reuse. The research finding to carry forward is the resolved contract above: keep function output separate from direct-execution formatting, and test those two surfaces independently. Implement production code and tests from scratch.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request. This is task 1 of 2. The tasks are assigned, completed, and merged serially in plan order. Do not start until this issue is assigned to the coding agent; task 2 must not start until this task is merged into the base branch.

## Implement

Implement subsection `1. Implement Fibonacci with unit and isolated CLI coverage`.

- Create repository-root `math-tool.ps1` with an integer parameter named `N`.
- Add a pure `Get-Fibonacci` function that accepts a non-negative integer and returns the Fibonacci number as a numeric value without writing incidental output.
- Make direct script execution print exactly one stdout line: `Fibonacci(N) = value`, substituting the supplied input and computed value.
- Ensure dot-sourcing the script for unit testing does not emit the direct-execution result line.
- Reject input outside the resolved non-negative-integer contract rather than computing a misleading result.
- Create repository-root `math-tool.Tests.ps1`.
- Add dot-sourced Pester unit tests for `Get-Fibonacci` covering `N=0`, `N=1`, and at least one small representative value greater than 1.
- Add isolated child-`pwsh` process tests for direct CLI execution covering the same categories. Assert the exact stdout line and ensure there is no extra stdout.
- Integrate through the existing repository-owned runner and pinned workflow without replacing their validation model.

## Completion gates

- `Get-Fibonacci 0` returns numeric `0`, `Get-Fibonacci 1` returns numeric `1`, and the representative value demonstrates the recurrence beyond the base cases.
- Dot-sourced invocation produces no incidental output before the function is called.
- A child process running `math-tool.ps1` produces exactly one correctly formatted line and exits successfully for every valid test case.
- At least one test demonstrates that invalid negative input is rejected and does not produce a success-shaped Fibonacci result line.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- The pull-request workflow using Pester 5.7.1 passes.
- Changes are limited to the math tool and its directly related tests unless a minimal correction to the existing runner is strictly required to execute those tests; do not alter the pinned Pester version.

## Out of scope

- Factorial calculation and operation dispatch belong to task 2.
- Do not rename or relocate the repository-owned runner, workflow, production script, or test file.
- Do not add dependencies, replace Pester, change the pinned Pester version, or introduce unrelated repository cleanup.
- Do not copy or adapt research/spike code.
