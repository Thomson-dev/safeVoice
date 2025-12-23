# Fix corrupted ic_launcher.png files by writing a tiny valid 1x1 PNG (transparent)
# Backups of existing files are created with .bak suffix.

$base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
$files = @(
  "C:\Users\Thomson\Documents\flutter\safe_voice\android\app\src\main\res\mipmap-mdpi\ic_launcher.png",
  "C:\Users\Thomson\Documents\flutter\safe_voice\android\app\src\main\res\mipmap-hdpi\ic_launcher.png",
  "C:\Users\Thomson\Documents\flutter\safe_voice\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png",
  "C:\Users\Thomson\Documents\flutter\safe_voice\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png",
  "C:\Users\Thomson\Documents\flutter\safe_voice\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
)

foreach ($f in $files) {
  $dir = Split-Path $f -Parent
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "Created directory: $dir"
  }
  if (Test-Path $f) {
    try {
      Copy-Item -Path $f -Destination ($f + ".bak") -Force
      Write-Host ([string]::Format("Backed up: {0} -> {0}.bak", $f))
    } catch {
      Write-Warning ([string]::Format("Failed to back up {0}: {1}", $f, $_))
    }
  }
  try {
    [IO.File]::WriteAllBytes($f, [Convert]::FromBase64String($base64))
    Write-Host ([string]::Format("Wrote valid PNG to: {0}", $f))
  } catch {
    Write-Error ([string]::Format("Failed to write {0}: {1}", $f, $_))
  }
}

Write-Host "Done. You can now run: flutter clean; flutter pub get; flutter build apk --release"