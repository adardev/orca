$ErrorActionPreference = 'Stop'

$ssh = 'C:\Program Files\Git\usr\bin\ssh.exe'
$alias = 'adardev-orca-20260928'

if (-not (Test-Path -LiteralPath $ssh)) {
    throw "No se encontró OpenSSH en $ssh"
}

Write-Host "Relay SSH activo: $alias"
Write-Host "Conecta desde Termux con:"
Write-Host "ssh -J serveo.net adaredu@$alias"
Write-Host "No cierres esta ventana mientras quieras acceso remoto."

& $ssh -NT `
    -o ServerAliveInterval=30 `
    -o ServerAliveCountMax=3 `
    -o ExitOnForwardFailure=yes `
    -o StrictHostKeyChecking=accept-new `
    -R "${alias}:22:127.0.0.1:22" `
    serveo.net
