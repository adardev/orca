# Acceso remoto a agentes por terminal

Este repositorio documenta el entorno para ejecutar agentes de código en Windows y controlarlos desde un teléfono Android usando Termux.

## Arquitectura

```text
Termux (Android)
    |
    | SSH through a reverse relay
    v
Windows + OpenSSH Server
    |
    v
Windows + OpenSSH Server -> Codex / Claude Code / OpenCode
```

El agente y los archivos permanecen en el PC. El teléfono solo funciona como cliente remoto.

## Estado actual

- OpenSSH Server está instalado y ejecutándose como servicio automático.
- El acceso remoto usa OpenSSH y un reverse relay SSH.
- El repositorio remoto estaba vacío al comenzar este trabajo.
- Todavía no se han guardado credenciales, tokens ni archivos de configuración secretos en este repositorio.

## Relay SSH

El relay se inicia desde `scripts/start-relay.ps1`. La ventana de PowerShell debe permanecer abierta mientras se necesite acceso remoto.

Desde Termux:

```bash
ssh -J serveo.net adaredu@adardev-orca-20260928-2
```

Después de entrar a Windows se puede ejecutar directamente `codex` desde el directorio del proyecto.

## Acceso desde Termux

El transporte remoto elegido para este entorno es un reverse relay SSH. El PC mantiene una conexión saliente al relay y el teléfono se conecta con SSH; no se necesita Tailscale ni abrir puertos en el router.

Instalar en Termux:

```bash
pkg update
pkg install openssh
```

Para una prueba con un relay gratuito, iniciar en Windows una conexión equivalente a:

```powershell
ssh -NT -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -R "ALIAS:22:127.0.0.1:22" serveo.net
```

El relay genera un alias temporal. Desde Termux se usa como salto SSH:

```bash
ssh -J serveo.net WINDOWS_USER@ALIAS
```

El alias gratuito puede cambiar y el proceso del relay debe permanecer ejecutándose en Windows. Para uso permanente conviene un VPS propio o un servicio con endpoint persistente.

## Requisitos pendientes

1. Crear una clave SSH en Termux y autorizar únicamente su clave pública en Windows.
2. Probar la conexión desde datos móviles y desde una red Wi-Fi externa.
3. Decidir si el relay temporal es suficiente o si se usará un VPS propio para tener un endpoint permanente.

No se deben subir al repositorio tokens del relay, claves privadas ni archivos `.env`.
