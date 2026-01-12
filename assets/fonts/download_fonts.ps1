# Script PowerShell pour télécharger Source Serif Pro
# Exécutez ce script depuis le dossier assets/fonts/

Write-Host "Téléchargement de Source Serif Pro..." -ForegroundColor Green

# Créer le dossier temporaire
$tempDir = "$env:TEMP\source_serif_pro"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# URL de téléchargement depuis GitHub (Adobe Source Serif Pro)
$fontUrl = "https://github.com/adobe-fonts/source-serif/releases/download/4.004R/source-serif-4.004R.zip"

Write-Host "Téléchargement depuis GitHub..." -ForegroundColor Yellow
try {
    $zipFile = "$tempDir\source-serif.zip"
    Invoke-WebRequest -Uri $fontUrl -OutFile $zipFile
    
    Write-Host "Extraction des fichiers..." -ForegroundColor Yellow
    
    # Extraire le ZIP
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    
    # Chercher les fichiers TTF
    $regularFont = Get-ChildItem -Path $tempDir -Recurse -Filter "*Regular*.ttf" | Select-Object -First 1
    $boldFont = Get-ChildItem -Path $tempDir -Recurse -Filter "*Bold*.ttf" | Select-Object -First 1
    
    if ($regularFont) {
        Copy-Item -Path $regularFont.FullName -Destination "SourceSerifPro-Regular.ttf" -Force
        Write-Host "✓ SourceSerifPro-Regular.ttf copié" -ForegroundColor Green
    } else {
        Write-Host "✗ Fichier Regular non trouvé" -ForegroundColor Red
    }
    
    if ($boldFont) {
        Copy-Item -Path $boldFont.FullName -Destination "SourceSerifPro-Bold.ttf" -Force
        Write-Host "✓ SourceSerifPro-Bold.ttf copié" -ForegroundColor Green
    } else {
        Write-Host "✗ Fichier Bold non trouvé" -ForegroundColor Red
    }
    
    # Nettoyer
    Remove-Item -Path $tempDir -Recurse -Force
    
    Write-Host "`nTéléchargement terminé !" -ForegroundColor Green
    Write-Host "Exécutez maintenant: flutter pub get" -ForegroundColor Cyan
    
} catch {
    Write-Host "Erreur lors du téléchargement: $_" -ForegroundColor Red
    Write-Host "`nTéléchargez manuellement depuis:" -ForegroundColor Yellow
    Write-Host "https://fonts.google.com/specimen/Source+Serif+Pro" -ForegroundColor Cyan
}

