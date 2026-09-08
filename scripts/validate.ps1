$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$pyScripts = "$env:APPDATA\Python\Python314\Scripts"
if (Test-Path $pyScripts) { $env:Path = "$pyScripts;$env:Path" }

Write-Host "==> yamllint weapons/"
python -m yamllint -c .yamllint.yml weapons
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> ruby ./scripts/validate_weapons.rb"
ruby ./scripts/validate_weapons.rb
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> ruby ./scripts/erb.rb"
ruby ./scripts/erb.rb
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "OK. Inspect git status; do not commit README.md or categorize/* in a PR."
git status --short
