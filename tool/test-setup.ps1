# Verifies the Firestore seed setup still works (e.g. after renaming the
# project folder). Run from the tool folder:
#   powershell -ExecutionPolicy Bypass -File test-setup.ps1

$ok = $true
function Check($label, $cond, $hint) {
    if ($cond) { Write-Host "OK   $label" -ForegroundColor Green }
    else {
        Write-Host "FAIL $label -- $hint" -ForegroundColor Red
        $script:ok = $false
    }
}

# 1. Script itself present?
Check "seed-firestore.mjs exists" `
    (Test-Path "seed-firestore.mjs") `
    "run this from the tool folder"

# 2. Seed JSON files resolve relative to the script location?
Check "assets/seed/beans.json exists" `
    (Test-Path "../assets/seed/beans.json") `
    "seed folder missing"
Check "assets/seed/shops.json exists" `
    (Test-Path "../assets/seed/shops.json") `
    "seed folder missing"

# 3. beans.json is valid JSON and non-empty?
try {
    $beans = Get-Content "../assets/seed/beans.json" -Raw | ConvertFrom-Json
    Check "beans.json valid ($($beans.Count) beans)" `
        ($beans.Count -gt 0) "file is empty or invalid"
} catch {
    Check "beans.json valid" $false "invalid JSON"
}

# 4. Credentials (defaults fill in when the window was reopened)
if (-not $env:GOOGLE_APPLICATION_CREDENTIALS) {
    $env:GOOGLE_APPLICATION_CREDENTIALS =
        "$env:USERPROFILE\Documents\roasted\service-account.json"
}
if (-not $env:FIREBASE_PROJECT_ID) {
    $env:FIREBASE_PROJECT_ID = "roasted-app-579f9"
}
Check "GOOGLE_APPLICATION_CREDENTIALS set" `
    ($env:GOOGLE_APPLICATION_CREDENTIALS) "set it manually"
Check "service-account.json exists" `
    (Test-Path $env:GOOGLE_APPLICATION_CREDENTIALS) `
    "not found at $($env:GOOGLE_APPLICATION_CREDENTIALS)"
Check "FIREBASE_PROJECT_ID=$($env:FIREBASE_PROJECT_ID)" `
    ($env:FIREBASE_PROJECT_ID -eq "roasted-app-579f9") "set it manually"

# 5. firebase-admin installed?
Check "firebase-admin installed" `
    (Test-Path "node_modules/firebase-admin") `
    "run: npm install firebase-admin"

if (-not $ok) {
    Write-Host "`nFix the FAIL lines above, then re-run." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nAll checks passed - running the real seed..." -ForegroundColor Cyan
node seed-firestore.mjs
