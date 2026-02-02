# Build and deploy Flutter Admin to Twizzy-BE
Write-Host "Building Flutter Web..." -ForegroundColor Cyan
flutter build web --release --base-href "/admin-web/"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Copying to Twizzy-BE/admin..." -ForegroundColor Cyan
    xcopy /E /I /Y "build\web" "d:\workspace\Twizzy\Twizzy-BE\admin" | Out-Null
    Write-Host "Done! Refresh browser at http://localhost:3000/admin-web/" -ForegroundColor Green
} else {
    Write-Host "Build failed!" -ForegroundColor Red
}
