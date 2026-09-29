$ErrorActionPreference = 'Stop'

$ssh = 'C:\Program Files\Git\usr\bin\ssh.exe'
$alias = 'adardev-orca-20260928-2'
$mutexName = 'Global\adardev-orca-serveo-relay'

if (-not (Test-Path -LiteralPath $ssh)) {
    throw "No se encontró OpenSSH en $ssh"
}

Write-Host "Relay SSH activo: $alias"
Write-Host "Conecta desde Termux con:"
Write-Host "ssh -J serveo.net adaredu@$alias"
Write-Host "El relay se reconectara solo usando siempre el mismo alias."

$mutex = New-Object System.Threading.Mutex($false, $mutexName)
if (-not $mutex.WaitOne(0)) {
    Write-Host "Ya hay otro relay ejecutandose con este alias."
    exit 1
}

try {
    while ($true) {
        Write-Host "Conectando relay..."
        & $ssh -NT `
            -o ServerAliveInterval=30 `
            -o ServerAliveCountMax=3 `
            -o ExitOnForwardFailure=yes `
            -o StrictHostKeyChecking=accept-new `
            -R "${alias}:22:127.0.0.1:22" `
            serveo.net

        Write-Host "Relay desconectado (codigo $LASTEXITCODE). Reintentando en 5 segundos..."
        Start-Sleep -Seconds 5
    }
}
finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
