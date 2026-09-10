## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `6-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

The resolved acceptance decision is that the canonical command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner; do not replace, bypass, or weaken either.

The resolved behavior contract is that direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`. Functions return only numeric values with no incidental output. Inputs are non-negative integers. The production and test files remain the repository-root `math-tool.ps1` and `math-tool.Tests.ps1`. This task depends on task 1 being merged and must preserve its Fibonacci behavior.

There are no spike implementations to reuse. The research finding to carry forward is the resolved contract above: operation dispatch must preserve the separation between pure numeric function returns and exact direct-execution formatting, while retaining the already-merged Fibonacci surface. Implement the extension and tests in production files without using research code as a template.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request. This is task 2 of 2 and depends on merged task 1. The tasks are assigned, completed, and merged serially in plan order. Do not start until this issue is assigned to the coding agent and task 1 has been merged into the base branch.

## Implement

Implement subsection `2. Add factorial and operation dispatch`.

- Extend repository-root `math-tool.ps1`; do not replace the task-1 implementation wholesale.
- Add a pure `Get-Factorial` function that accepts a non-negative integer and returns its factorial as a numeric value without writing incidental output.
- Add an `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the `N` parameter.
- Preserve the existing Fibonacci invocation and output behavior from task 1. If task 1 permits invocation without `Operation`, keep that form working as Fibonacci rather than making the previously valid call fail.
- For direct factorial execution, print exactly one stdout line: `Factorial(N) = value`, substituting the supplied input and computed value.
- Constrain dispatch to the supported `fibonacci` and `factorial` operations and reject unsupported values rather than silently selecting an operation.
- Extend repository-root `math-tool.Tests.ps1` with focused unit and isolated child-process coverage. Preserve all Fibonacci regression coverage.
- Cover factorial `N=0`, `N=1`, and at least one small representative value greater than 1.
- Integrate through the existing repository-owned runner and pinned workflow without replacing their validation model.

## Completion gates

- `Get-Factorial 0` and `Get-Factorial 1` each return numeric `1`; the representative value demonstrates multiplication beyond the base cases.
- Calling either pure function returns only its numeric value, and dot-sourcing the script emits no direct-execution output.
- Isolated child-process tests assert exact, single-line stdout for both dispatch paths, including `Fibonacci(N) = value` and `Factorial(N) = value`.
- The full task-1 Fibonacci unit and CLI suite remains green, including any previously valid invocation that omits `Operation`.
- At least one test demonstrates that an unsupported operation is rejected without a success-shaped result line.
- At least one test demonstrates that invalid negative input is rejected for factorial without a success-shaped result line.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- The pull-request workflow using Pester 5.7.1 passes.
- Changes remain objective and small, limited to the existing math tool and directly related tests unless a minimal correction to the existing runner is strictly required; do not alter the pinned Pester version.

## Out of scope

- Do not add operations beyond `fibonacci` and `factorial`.
- Do not rename or relocate the repository-owned runner, workflow, production script, or test file.
- Do not add dependencies, replace Pester, change the pinned Pester version, or refactor unrelated code.
- Do not copy or adapt research/spike code.
