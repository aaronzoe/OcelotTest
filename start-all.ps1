# Start all services script
# Usage: .\start-all.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Ocelot Test Project" -ForegroundColor Cyan
Write-Host "  With Load Balancing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .NET SDK is installed
try {
    $dotnetVersion = dotnet --version
    Write-Host ".NET SDK Version: $dotnetVersion" -ForegroundColor Green
}
catch {
    Write-Host "Error: .NET SDK not found, please install .NET 8.0 SDK" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Restore dependencies
Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Restore failed" -ForegroundColor Red
    exit 1
}
Write-Host "Restore completed" -ForegroundColor Green
Write-Host ""

# Build project
Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "Build completed" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Please run the following commands in FOUR separate terminals:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Terminal 1 - ServiceA (Port 5001):" -ForegroundColor White
Write-Host "  cd ServiceA; dotnet run --launch-profile http" -ForegroundColor Gray
Write-Host ""
Write-Host "Terminal 2 - ServiceA2 (Port 5003) [Load Balancing]:" -ForegroundColor White
Write-Host "  cd ServiceA2; dotnet run --launch-profile http" -ForegroundColor Gray
Write-Host ""
Write-Host "Terminal 3 - ServiceB (Port 5002):" -ForegroundColor White
Write-Host "  cd ServiceB; dotnet run --launch-profile http" -ForegroundColor Gray
Write-Host ""
Write-Host "Terminal 4 - Ocelot Gateway (Port 5000):" -ForegroundColor White
Write-Host "  cd OcelotGateway; dotnet run --launch-profile http" -ForegroundColor Gray
Write-Host ""
Write-Host "After all services are started, run the test script:" -ForegroundColor Yellow
Write-Host "  .\test-api.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Or manually access:" -ForegroundColor Yellow
Write-Host "  Gateway: http://localhost:5000" -ForegroundColor Gray
Write-Host "  ServiceA Swagger: http://localhost:5001/swagger" -ForegroundColor Gray
Write-Host "  ServiceA2 Swagger: http://localhost:5003/swagger" -ForegroundColor Gray
Write-Host "  ServiceB Swagger: http://localhost:5002/swagger" -ForegroundColor Gray
Write-Host ""
Write-Host "Load Balancing Info:" -ForegroundColor Yellow
Write-Host "  - ServiceA and ServiceA2 use RoundRobin load balancing" -ForegroundColor Gray
Write-Host "  - Requests to /servicea/* will alternate between 5001 and 5003" -ForegroundColor Gray
Write-Host ""
