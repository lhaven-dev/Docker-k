$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Image = "hello-world-tp:1.0"
$Container = "hello-world-tp-run"

docker build -t $Image "$Root\app"

if (docker ps -a -q -f "name=$Container") {
    docker rm -f $Container | Out-Null
}

docker run -d --name $Container -p 3000:3000 $Image
Start-Sleep -Seconds 2

curl.exe -s http://localhost:3000/
Write-Host ""
curl.exe -s http://localhost:3000/health
Write-Host ""
