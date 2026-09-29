# Acceso remoto a agentes por terminal

Este repositorio documenta el entorno para ejecutar agentes de código en Windows y controlarlos desde un teléfono Android usando Termux.

## Arquitectura

```text
Termux (Android)
    |
    | SSH + cloudflared / Cloudflare Access
    v
Windows + OpenSSH Server
    |
    v
Zellij -> Codex / Claude Code / OpenCode
```

El agente y los archivos permanecen en el PC. El teléfono solo funciona como cliente remoto.

## Estado actual

- OpenSSH Server está instalado y ejecutándose como servicio automático.
- Zellij `0.45.1` está instalado en el perfil del usuario.
- Cloudflared `2026.9.3` está instalado en el perfil del usuario.
- El servicio `cloudflared` está instalado y ejecutándose automáticamente en Windows.
- El repositorio remoto estaba vacío al comenzar este trabajo.
- Todavía no se han guardado credenciales, tokens ni archivos de configuración secretos en este repositorio.

## Sesión local de Zellij

Desde PowerShell, dentro del checkout del proyecto:

```powershell
zellij --session proyecto
codex
```

Para volver a una sesión existente:

```powershell
zellij attach proyecto
```

Una sesión de Zellij permanece disponible aunque se cierre el terminal cliente.

## Acceso desde Termux

Instalar en Termux:

```bash
pkg update
pkg install openssh cloudflared
```

La conexión remota se configurará mediante un hostname protegido por Cloudflare Access. El archivo `~/.ssh/config` del teléfono tendrá una entrada equivalente a:

```ssh
Host mi-pc
    HostName ssh.example.com
    User WINDOWS_USER
    ProxyCommand cloudflared access ssh --hostname %h
```

Conectar:

```bash
ssh mi-pc
```

Después de entrar a Windows, recuperar la sesión:

```powershell
zellij attach proyecto
```

## Requisitos pendientes

1. Añadir una ruta publicada al túnel: `ssh://localhost:22`.
2. Crear una aplicación Cloudflare Access para el hostname SSH.
3. Rotar el token del conector si fue expuesto durante la instalación.
4. Crear una clave SSH para Termux y autorizar únicamente su clave pública en Windows.
5. Probar la conexión desde datos móviles y desde una red Wi-Fi externa.

No se deben subir al repositorio las credenciales de Cloudflare, tokens de túnel, claves privadas ni archivos `.env`.
