#!/usr/bin/env pwsh
# Script to install pre-commit using pip

Write-Host "Installing pre-commit..." -ForegroundColor Green

# Install pre-commit
pip install pre-commit

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ pre-commit installed successfully" -ForegroundColor Green
    
    # Install the git hooks
    Write-Host "`nVerifying installation..." -ForegroundColor Green
    pre-commit --version
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ pre-commit installed successfully" -ForegroundColor Green
        Write-Host "`nYou can now run 'pre-commit run --all-files' to check all files" -ForegroundColor Cyan
        Write-Host "`nTo install the git hooks for the repository, run 'pre-commit install'" -ForegroundColor Cyan

    } else {
        Write-Host "✗ Failed to install git hooks" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Failed to install pre-commit" -ForegroundColor Red
    exit 1
}
