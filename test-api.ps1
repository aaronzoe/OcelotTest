# Ocelot Gateway Test Script
# Make sure all services are running before executing

$gatewayUrl = "http://localhost:5000"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ocelot Gateway API Forwarding Test" -ForegroundColor Cyan
Write-Host "  With Load Balancing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if gateway is running
try {
    $response = Invoke-WebRequest -Uri "$gatewayUrl/" -UseBasicParsing -TimeoutSec 5
    Write-Host "[1/11] Gateway Status: " -NoNewline
    Write-Host "OK" -ForegroundColor Green
}
catch {
    Write-Host "Error: Gateway not running. Please start OcelotGateway, ServiceA, ServiceA2, and ServiceB first." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 1: ServiceA Hello
Write-Host "[2/11] Testing ServiceA Hello..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/servicea/hello" -Method Get
    Write-Host "  Response: " -NoNewline
    Write-Host $result.Message -ForegroundColor Green
    Write-Host "  From Service: $($result.Service)"
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: ServiceB Hello
Write-Host "[3/11] Testing ServiceB Hello..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/serviceb/hello" -Method Get
    Write-Host "  Response: " -NoNewline
    Write-Host $result.Message -ForegroundColor Green
    Write-Host "  From Service: $($result.Service)"
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: ServiceA Info
Write-Host "[4/11] Testing ServiceA Info..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/servicea/info" -Method Get
    Write-Host "  Service: $($result.Service)"
    Write-Host "  Version: $($result.Version)"
    Write-Host "  Port: $($result.Port)"
    Write-Host "  Status: " -NoNewline
    Write-Host $result.Status -ForegroundColor Green
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: ServiceB Info
Write-Host "[5/11] Testing ServiceB Info..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/serviceb/info" -Method Get
    Write-Host "  Service: $($result.Service)"
    Write-Host "  Version: $($result.Version)"
    Write-Host "  Status: " -NoNewline
    Write-Host $result.Status -ForegroundColor Green
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Load Balancing Test - Round Robin
Write-Host "[6/11] Testing Load Balancing (Round Robin)..." -ForegroundColor Yellow
$serviceCounts = @{}
try {
    for ($i = 1; $i -le 6; $i++) {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/servicea/hello" -Method Get
        $svc = $result.Service
        if (-not $serviceCounts.ContainsKey($svc)) {
            $serviceCounts[$svc] = 0
        }
        $serviceCounts[$svc]++
        Write-Host "  Request $i - From: $svc"
    }
    Write-Host "  Load distribution:"
    foreach ($svc in $serviceCounts.Keys) {
        Write-Host "    $($svc): $($serviceCounts[$svc]) requests"
    }
    if ($serviceCounts.Count -gt 1) {
        Write-Host "  Load balancing: " -NoNewline
        Write-Host "Working" -ForegroundColor Green
    }
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: ServiceA User
Write-Host "[7/11] Testing ServiceA User (ID: 42)..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/servicea/users/42" -Method Get
    Write-Host "  User ID: $($result.UserId)"
    Write-Host "  User Name: " -NoNewline
    Write-Host $result.Name -ForegroundColor Green
    Write-Host "  From Service: $($result.Service)"
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 7: ServiceB Product
Write-Host "[8/11] Testing ServiceB Product (ID: 101)..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/serviceb/products/101" -Method Get
    Write-Host "  Product ID: $($result.ProductId)"
    Write-Host "  Product Name: " -NoNewline
    Write-Host $result.Name -ForegroundColor Green
    Write-Host "  Price: $($result.Price)"
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 8: ServiceB Orders
Write-Host "[9/11] Testing ServiceB Orders..." -ForegroundColor Yellow
try {
    $result = Invoke-RestMethod -Uri "$gatewayUrl/serviceb/orders" -Method Get
    Write-Host "  Total Orders: " -NoNewline
    Write-Host $result.Total -ForegroundColor Green
    foreach ($order in $result.Orders) {
        Write-Host "    - Order #$($order.OrderId): $($order.Product) x $($order.Quantity)"
    }
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 9: Special Weather Route with Load Balancing
Write-Host "[10/11] Testing Special Route /weather with Load Balancing..." -ForegroundColor Yellow
$weatherServices = @()
try {
    for ($i = 1; $i -le 4; $i++) {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/weather" -Method Get
        $weatherServices += $result.Service
        Write-Host "  Request $i - From: $($result.Service), Forecast days: $($result.Forecast.Length)"
    }
    $uniqueServices = $weatherServices | Select-Object -Unique
    if ($uniqueServices.Count -gt 1) {
        Write-Host "  Weather endpoint load balancing: " -NoNewline
        Write-Host "Working" -ForegroundColor Green
    }
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 10: POST Data to ServiceA with Load Balancing
Write-Host "[11/11] Testing POST Data with Load Balancing..." -ForegroundColor Yellow
try {
    $body = @{ name = "TestItem"; value = "TestValue123" } | ConvertTo-Json
    $postServices = @()
    for ($i = 1; $i -le 3; $i++) {
        $result = Invoke-RestMethod -Uri "$gatewayUrl/servicea/data" -Method Post -Body $body -ContentType "application/json"
        $postServices += $result.Service
        Write-Host "  POST Request $i - From: $($result.Service), Status: $($result.Status)"
    }
    $uniquePostServices = $postServices | Select-Object -Unique
    if ($uniquePostServices.Count -gt 1) {
        Write-Host "  POST load balancing: " -NoNewline
        Write-Host "Working" -ForegroundColor Green
    }
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
