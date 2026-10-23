# Acceso SSH al servidor Tekkure por Serveo

Este repositorio contiene el relay que corre en la PC Windows de la LAN del servidor Tekkure. La PC mantiene una conexión SSH saliente a Serveo y reenvía el puerto remoto del alias al SSH del servidor (`192.168.0.127:22`). El servidor no requiere instalar Serveo ni abrir el puerto 22 en el router.

## Iniciar el relay

Abre el acceso directo `Iniciar relay SSH`, que ejecuta `scripts/start-relay.ps1`. La PC debe permanecer encendida, conectada a la misma LAN del servidor y con el relay activo. El script reintenta automáticamente si la conexión a Serveo se interrumpe y evita abrir dos relays con el mismo alias.

La dirección `192.168.0.127` se asigna por DHCP. Reserva esa dirección para el servidor en el router; si cambia, actualiza el destino `-R` del script y sincroniza la documentación del repositorio `Tekkure-Systems/tekkure-server`.

## Conectarse desde otra red

Desde un cliente con OpenSSH:

```bash
ssh -J serveo.net tekkure@adardev-orca-20261020-f9c7e2
```

En la laptop configurada, `ssh tekkure` usa el alias local de `~/.ssh/config`, el salto por Serveo y la llave cliente `~/.ssh/id_ed25519_tekkure_auto`. La clave pública correspondiente debe estar autorizada en `/home/tekkure/.ssh/authorized_keys` del servidor.

Serveo solo transporta la conexión. Conserva la verificación de `known_hosts` y la autenticación del usuario `tekkure`. La huella ED25519 verificada del servidor es `SHA256:9xfB9e3PIzVMIuUWaPOGxSfMWVvYikQxiMmTCoG5JCs`. El alias es un nombre de ruta, no una credencial.

## Claves locales

- `~/.ssh/serveo_adardev_orca_ed25519`: autentica la PC relay ante Serveo.
- `~/.ssh/id_ed25519_tekkure_auto`: autentica la laptop cliente ante el servidor Tekkure.

Las claves privadas, contraseñas y tokens nunca se guardan en Git. La configuración SSH del cliente tampoco se versiona porque contiene rutas locales.
