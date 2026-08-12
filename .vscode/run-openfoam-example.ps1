param(
    [string]$Case = "tutorials/legacy/incompressible/icoFoam/cavity",
    [string]$Output = "runs/cavity",
    [switch]$NoRun
)

$ErrorActionPreference = "Stop"

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourceCase = Join-Path $workspaceRoot $Case
$targetCase = Join-Path $workspaceRoot $Output

if (-not (Test-Path $sourceCase)) {
    Write-Error "Source case not found: $Case"
    exit 1
}

Write-Host "Preparing OpenFOAM case from $Case..."
if (Test-Path $targetCase) {
    Remove-Item -Path $targetCase -Recurse -Force
}
Copy-Item -Path $sourceCase -Destination $targetCase -Recurse
Write-Host "Case copied to $Output"

if ($NoRun) {
    Write-Host "Case prepared. Run the OpenFOAM task again without -NoRun to execute it."
    exit 0
}

$foamRuntimeDetected = $false
if ($env:WM_PROJECT_DIR -and (Test-Path $env:WM_PROJECT_DIR)) {
    $foamRuntimeDetected = $true
}
elseif (Get-Command foam -ErrorAction SilentlyContinue) {
    $foamRuntimeDetected = $true
}

if (-not $foamRuntimeDetected) {
    Write-Host "OpenFOAM runtime was not detected."
    Write-Host "Install OpenFOAM or load its environment before running a simulation."
    Write-Host "Example: source $workspaceRoot/etc/bashrc"
    exit 1
}

Set-Location $targetCase

if (Test-Path "Allrun") {
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        & bash -lc "./Allrun"
    }
    else {
        Write-Error "Bash is required to run the tutorial Allrun script."
        exit 1
    }
}
else {
    if (Get-Command blockMesh -ErrorAction SilentlyContinue) {
        & blockMesh
    }
    else {
        Write-Error "blockMesh was not found. The OpenFOAM environment may not be loaded."
        exit 1
    }

    if (Get-Command icoFoam -ErrorAction SilentlyContinue) {
        & icoFoam
    }
    else {
        Write-Error "icoFoam was not found. The OpenFOAM environment may not be loaded."
        exit 1
    }
}
