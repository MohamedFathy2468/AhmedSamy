# Asset Normalization Script
# This script will normalize all file names and folder structure

Write-Host "Starting asset normalization..." -ForegroundColor Green

# Create normalized directory structure
$basePath = "d:\RANDOM\My-Portfolio"
$newImagesPath = Join-Path $basePath "assets\images"
$newIconsPath = Join-Path $basePath "assets\icons"
$newCertificatesPath = Join-Path $newImagesPath "certificates"

# Create directories
New-Item -ItemType Directory -Force -Path $newImagesPath | Out-Null
New-Item -ItemType Directory -Force -Path $newIconsPath | Out-Null
New-Item -ItemType Directory -Force -Path $newCertificatesPath | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $newImagesPath "photos") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $newCertificatesPath "2024") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $newCertificatesPath "2025") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $newCertificatesPath "2026") | Out-Null

Write-Host "Created normalized directory structure" -ForegroundColor Green

# Function to sanitize filename
function Sanitize-Filename {
    param([string]$filename)
    # Remove spaces, convert to lowercase, replace special chars
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    $ext = [System.IO.Path]::GetExtension($filename)
    $name = $name -replace '\s+', '-' -replace '[^a-zA-Z0-9\-]', '' -replace '--+', '-'
    $name = $name.ToLower()
    return "$name$ext"
}

# Copy and rename SVG files (icons)
Write-Host "Processing SVG icons..." -ForegroundColor Yellow
$svgSource = Join-Path $basePath "assets\svg"
if (Test-Path $svgSource) {
    Get-ChildItem -Path $svgSource -Filter "*.svg" | ForEach-Object {
        $newName = Sanitize-Filename $_.Name
        Copy-Item $_.FullName -Destination (Join-Path $newIconsPath $newName) -Force
        Write-Host "  Copied: $($_.Name) -> $newName" -ForegroundColor Gray
    }
}

# Copy certificates
Write-Host "Processing certificates..." -ForegroundColor Yellow
foreach ($year in @("2024", "2025", "2026")) {
    $yearPath = Join-Path $basePath "assets\imgs\$year"
    if (Test-Path $yearPath) {
        Get-ChildItem -Path $yearPath -File | ForEach-Object {
            $newName = Sanitize-Filename $_.Name
            Copy-Item $_.FullName -Destination (Join-Path (Join-Path $newCertificatesPath $year) $newName) -Force
            Write-Host "  Copied: $year\$($_.Name) -> $newName" -ForegroundColor Gray
        }
    }
}

# Copy photos (the problematic ones with spaces)
Write-Host "Processing photos..." -ForegroundColor Yellow
$photosSource = Join-Path $basePath "assets\imgs\pics"
$photosDest = Join-Path $newImagesPath "photos"
$photoMap = @{}

if (Test-Path $photosSource) {
    Get-ChildItem -Path $photosSource -File | ForEach-Object {
        $newName = Sanitize-Filename $_.Name
        $newPath = Join-Path $photosDest $newName
        Copy-Item $_.FullName -Destination $newPath -Force
        $photoMap[$_.Name] = "assets/images/photos/$newName"
        Write-Host "  Copied: $($_.Name) -> $newName" -ForegroundColor Gray
    }
}

# Copy other images
Write-Host "Processing other images..." -ForegroundColor Yellow
$imagesToCopy = @("profile.jpg", "Ather.png", "resala.jpeg", "channels4_banner.jpg", "app.png", "landingPage.png", "webApp.png")
foreach ($img in $imagesToCopy) {
    $sourcePath = Join-Path $basePath "assets\imgs\$img"
    if (Test-Path $sourcePath) {
        $newName = Sanitize-Filename $img
        Copy-Item $sourcePath -Destination (Join-Path $newImagesPath $newName) -Force
        Write-Host "  Copied: $img -> $newName" -ForegroundColor Gray
    }
}

Write-Host "`nNormalization complete!" -ForegroundColor Green
Write-Host "New structure:" -ForegroundColor Cyan
Write-Host "  assets/images/ - main images" -ForegroundColor White
Write-Host "  assets/images/certificates/ - certificates by year" -ForegroundColor White
Write-Host "  assets/images/photos/ - photo album images" -ForegroundColor White
Write-Host "  assets/icons/ - SVG icons" -ForegroundColor White
Write-Host "`nNext: Update HTML references" -ForegroundColor Yellow
