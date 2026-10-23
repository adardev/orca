$ErrorActionPreference = 'Stop'

$ssh = 'C:\Program Files\Git\usr\bin\ssh.exe'
$key = Join-Path $env:USERPROFILE '.ssh\serveo_adardev_orca_ed25519'
$alias = 'adardev-orca-20261020-f9c7e2'
$mutexName = 'Global\adardev-orca-serveo-relay'

if (-not (Test-Path -LiteralPath $ssh)) {
    throw "No se encontró OpenSSH en $ssh"
}
if (-not (Test-Path -LiteralPath $key)) {
    throw "No se encontró la clave SSH de Serveo en $key"
}

Write-Host "Iniciando relay SSH para: $alias"
Write-Host "Conecta desde cualquier red con:"
Write-Host "ssh -J serveo.net tekkure@$alias"
Write-Host "El relay se reconectara solo usando siempre el mismo alias."

$mutex = New-Object System.Threading.Mutex($false, $mutexName)
if (-not $mutex.WaitOne(0)) {
    Write-Host "Ya hay otro relay ejecutandose con este alias."
    exit 1
}

try {
    while ($true) {
        Write-Host "Conectando relay..."
        $readyShown = $false
        $permissionDenied = $false
        $previousErrorPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        # -v permite reconocer la confirmacion del reenvio remoto; filtramos el resto del diagnostico.
        & $ssh -v -NT `
            -i $key `
            -o IdentitiesOnly=yes `
            -o ServerAliveInterval=30 `
            -o ServerAliveCountMax=3 `
            -o ExitOnForwardFailure=yes `
            -o StrictHostKeyChecking=accept-new `
            -R "${alias}:22:192.168.0.127:22" `
            serveo.net 2>&1 | ForEach-Object {
                $line = "$_"
                if (-not $readyShown -and $line -match 'remote forward success for: listen') {
                    Write-Host "Relay listo. Ya puedes conectarte desde otra red con:"
                    Write-Host "ssh -J serveo.net tekkure@$alias"
                    $readyShown = $true
                }
                elseif ($line -match 'Permission denied|remote port forwarding failed|Could not resolve hostname|Connection timed out|Connection refused|REMOTE HOST IDENTIFICATION HAS CHANGED|^ssh:') {
                    Write-Host $line
                    if ($line -match 'Permission denied') { $permissionDenied = $true }
                }
            }
        $sshExitCode = $LASTEXITCODE
        $ErrorActionPreference = $previousErrorPreference

        if ($permissionDenied) {
            Write-Host "Serveo rechazo la clave. Agrega esta clave publica a tu cuenta de Serveo y vuelve a abrir Orca:"
            Get-Content -LiteralPath ($key + '.pub') | Write-Host
            break
        }

        Write-Host "Relay desconectado (codigo $sshExitCode). Reintentando en 5 segundos..."
        Start-Sleep -Seconds 5
    }
}
finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
