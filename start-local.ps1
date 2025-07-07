# DingQ Local Development Automation Script

param(
    [switch]$Build,
    [switch]$Clean,
    [switch]$Logs,
    [switch]$Test,
    [switch]$Stop
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 DingQ Local Development Manager" -ForegroundColor Green
Write-Host "=" * 40 -ForegroundColor Gray

if ($Clean) {
    Write-Host "🧹 Cleaning up containers and volumes..." -ForegroundColor Yellow
    docker-compose down --volumes --remove-orphans
    docker system prune -f
    Write-Host "✅ Cleanup completed!" -ForegroundColor Green
    exit 0
}

if ($Stop) {
    Write-Host "🛑 Stopping all services..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ Services stopped!" -ForegroundColor Green
    exit 0
}

if ($Logs) {
    Write-Host "📋 Showing service logs..." -ForegroundColor Blue
    docker-compose logs -f
    exit 0
}

# Default: Start services
Write-Host "🐳 Starting DingQ services..." -ForegroundColor Blue

if ($Build) {
    Write-Host "🏗️ Building Docker images..." -ForegroundColor Blue
    docker-compose build --no-cache
}

# Start services
docker-compose up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Blue
Start-Sleep -Seconds 15

# Check health
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✅ Backend is healthy!" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Backend health check failed" -ForegroundColor Yellow
}

# Test basic functionality
if ($Test) {
    Write-Host "🧪 Running basic API tests..." -ForegroundColor Blue
    
    # Test health endpoint
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "   Health: $($healthData.status)" -ForegroundColor Cyan
        Write-Host "   Model: $($healthData.model_loaded)" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ Health test failed" -ForegroundColor Red
    }
    
    # Test docs endpoint
    try {
        $docsResponse = Invoke-WebRequest -Uri "http://localhost:8000/docs" -UseBasicParsing
        if ($docsResponse.StatusCode -eq 200) {
            Write-Host "   ✅ API docs accessible" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ API docs test failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🌐 Service URLs:" -ForegroundColor Blue
Write-Host "   Backend API: http://localhost:8000" -ForegroundColor Cyan
Write-Host "   API Docs: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "   Health Check: http://localhost:8000/health" -ForegroundColor Cyan

Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Blue
Write-Host "   .\start-local.ps1 -Logs    # View logs" -ForegroundColor Gray
Write-Host "   .\start-local.ps1 -Stop    # Stop services" -ForegroundColor Gray
Write-Host "   .\start-local.ps1 -Clean   # Clean up everything" -ForegroundColor Gray
Write-Host "   .\start-local.ps1 -Build   # Rebuild images" -ForegroundColor Gray
Write-Host "   .\start-local.ps1 -Test    # Run basic tests" -ForegroundColor Gray 