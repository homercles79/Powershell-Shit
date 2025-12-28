 # --- Configuration ---
$sourceDir = "C:\Path\To\Source"      # Directory to compress
$destinationDir = "C:\Path\To\Output"     # Where to save the tarball
$outputFileName = "Archive_$(Get-Date -Format 'yyyyMMdd_HHmm').tar.gz"

# --- Logic ---
$outputPath = Join-Path -Path $destinationDir -ChildPath $outputFileName

# Check if source exists
if (!(Test-Path $sourceDir)) {
    Write-Error "Source directory does not exist: $sourceDir"
    return
}

#Ensure destination directory exists
if (!(Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir | Out-Null
}

Write-Host "Creating tarball at: $outputPath..." -ForegroundColor Cyan

# Execute tar command
tar.exe -czf $outputPath -C $sourceDir .

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Tarball created successfully." -ForegroundColor Green
} else {
    Write-Error "Tarball creation failed."
}
