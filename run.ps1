$env:PYTHONUTF8 = "1"

Get-Content .env | ForEach-Object {
    $name, $value = $_ -split '=', 2
    $value = $value.Trim()
    [System.Environment]::SetEnvironmentVariable($name, $value)
}

Write-Host "Variables chargees. Lancement de dbt..." -ForegroundColor Green

switch ($args[0]) {
    "run"   { dbt run --profiles-dir . }
    "test"  { dbt test --profiles-dir . }
    "debug" { dbt debug --profiles-dir . }
    "all"   { dbt run --profiles-dir . ; dbt test --profiles-dir . }
    default { dbt run --profiles-dir . }
}