#!/usr/bin/env pwsh
# Script to install tflint using winget

Write-Host "Installing tflint..." -ForegroundColor Green

# Install tflint
choco install tflint

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ tflint installed successfully" -ForegroundColor Green
    
    # Verify installation
    Write-Host "`nVerifying installation..." -ForegroundColor Green
    tflint --version
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ tflint is ready to use" -ForegroundColor Green
        Write-Host "`nYou can now run 'tflint' to lint your Terraform files" -ForegroundColor Cyan
    } else {
        Write-Host "✗ tflint installation could not be verified. You may need to restart your terminal." -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Failed to install tflint" -ForegroundColor Red
    exit 1
}
