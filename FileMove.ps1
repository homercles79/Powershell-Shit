# ===== CONFIGURE THESE PATHS =====
$SourceDirectory = "C:\Path\To\Source
$DestinationDirectory = "C:\Path\To\Destination"

# Create destination folder if it doesn't exist
if (!(Test-Path $DestinationDirectory)) {
    New-Item -ItemType Directory -Path $DestinationDirectory | Out-Null
}

# Build a hash table of existing destination files
$existingHashes = @{}

#Change -Filter *.ABC to extension of file tyupe you want to move
Get-ChildItem -Path $DestinationDirectory -Filter *.ABC -File | ForEach-Object {
    $hash = Get-FileHash $_.FullName -Algorithm SHA256
    $existingHashes[$hash.Hash] = $_.FullName
}

# Process source files
Get-ChildItem -Path $SourceDirectory -Recurse -Filter *.ttf -File | ForEach-Object {

    $sourceHash = Get-FileHash $_.FullName -Algorithm SHA256

    # Skip if duplicate content exists
    if ($existingHashes.ContainsKey($sourceHash.Hash)) {
        Write-Host "Duplicate skipped: $($_.FullName)"
        return
    }

    # Resolve filename collisions
    $destinationPath = Join-Path $DestinationDirectory $_.Name
    if (Test-Path $destinationPath) {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $ext = $_.Extension
        $count = 1
        do {
            $destinationPath = Join-Path $DestinationDirectory "$base`_$count$ext"
            $count++
        } while (Test-Path $destinationPath)
    }

    # Move file
    Move-Item $_.FullName $destinationPath

    # Record hash so future duplicates are skipped
    $existingHashes[$sourceHash.Hash] = $destinationPath
}

Write-Host "Done! Duplicate files were skipped."
