# Servir Memini desde ZimaOS

[English](ZIMAOS.md) · **Español**

Cómo servir la compilación web/PWA de Memini desde un servidor ZimaOS doméstico
(STACK-APPS-DINAMICAS.md 5.A).

**Antes que nada:** el servidor **solo sirve la app**. Las entradas de cada persona
viven en **su propio navegador o dispositivo**, no en ZimaOS. Dos personas
que usan el mismo servidor no comparten nada, y quien borre los datos del sitio o
quite la app pierde lo que no haya exportado. El backup es el export JSON
en Ajustes → Tus datos → Exportar.

## 1. La imagen

Cada tag `v*` construye y sube `ghcr.io/iezappa/memini:<versión>` y
`:latest` para `amd64` y `arm64` (`.github/workflows/release.yml`).

La primera vez, haz **público** el paquete: GitHub → Packages → `memini` →
Package settings → Change visibility → Public. ZimaOS no puede descargar un paquete
privado sin credenciales.

## 2. Instalar en ZimaOS

1. `deploy/docker-compose.yml` ya viene completo. Cambia el puerto `8082` (tanto
   `published` como `port_map`) solo si está ocupado en tu servidor.
2. ZimaOS → **App Store** → **"+"** → **Install a customized app**.
3. **Import** el `docker-compose.yml` y revisa la imagen y el puerto.
4. **Install**. El ícono de Memini aparece en el escritorio de ZimaOS.
5. Comprueba que carga en `http://<ip-de-zimaos>:8082`. **Esa URL es solo para
   comprobar**, no para el uso diario (ver paso 3).

Los nombres de los menús cambian entre versiones de ZimaOS; si no están estos,
busca la opción de instalación personalizada o de importar docker-compose.

## 3. HTTPS con Tailscale

Instalar la PWA, su service worker y el almacenamiento OPFS necesitan HTTPS.
`http://IP:puerto` carga, pero no se puede instalar y puede perder esas funciones.

1. Instala **Tailscale** desde la App Store de ZimaOS e inicia sesión.
2. En la consola de administración de Tailscale habilita **MagicDNS** y **HTTPS
   Certificates**.
3. En ZimaOS (SSH):

   ```bash
   tailscale serve --bg http://127.0.0.1:8082
   tailscale serve status
   ```

   Si Tailscale corre como contenedor, ejecútalo dentro de ese contenedor apuntando a la
   IP de red local del servidor en lugar de `127.0.0.1`.
4. Memini queda entonces en `https://<servidor>.<tailnet>.ts.net/`.
5. Cada persona que la use instala Tailscale y se une a la tailnet.

**Usa siempre la URL `ts.net`, también en casa.** El almacenamiento del navegador es por origen:
las entradas guardadas a través de la IP local no aparecen a través de `ts.net`, y
viceversa.

## 4. Instalar en cada dispositivo

| Dispositivo | Cómo |
|---|---|
| iPhone / iPad | Abre la URL `ts.net` en **Safari** → Compartir → **Agregar a inicio**. Ábrela siempre desde ese ícono. |
| Android | Chrome → menú → **Instalar app**. O el APK de GitHub Releases, que no necesita servidor. |
| Windows / macOS / Linux | Chrome o Edge → ícono de instalar en la barra de direcciones. O la compilación de la versión. |

Ábrela una vez con conexión y luego comprueba que Ajustes → Tus datos → Exportar
funciona.

## 5. Búsquedas, cabeceras y lo que permite el navegador

nginx envía `Cross-Origin-Opener-Policy: same-origin` y
`Cross-Origin-Embedder-Policy: require-corp`, para que Drift pueda usar OPFS.

- Las búsquedas (TMDB, RAWG, MusicBrainz) son peticiones `fetch` en modo CORS.
  COEP no las bloquea: solo bloquea subrecursos *no-cors* (como un
  `<img>` de otro host) que no envían `Cross-Origin-Resource-Policy`.
  Las API responden con `Access-Control-Allow-Origin`, que es lo que hace que las
  búsquedas funcionen en un navegador, con o sin estas cabeceras.
- Memini no carga imágenes remotas e incluye sus fuentes; CanvasKit también va
  incluido (`--no-web-resources-cdn`). Si un cambio futuro muestra imágenes remotas, pruébalo
  aquí: COEP las bloquearía.
- Este cambio no se verificó en un equipo ZimaOS real. Si una búsqueda falla solo en
  el contenedor, abre la consola del navegador: un error de COEP o CORS nombra la
  petición bloqueada.

## 6. Datos y backups

- Cada persona exporta su JSON con regularidad (la app se lo recuerda) y lo guarda
  fuera del navegador.
- Para pasar a otro dispositivo: exporta en el viejo, importa en el nuevo.
- Reinstalar o actualizar el contenedor no toca los datos de nadie.

## 7. Actualizar

1. Crea un tag de versión nuevo; el workflow actualiza `:latest`.
2. En ZimaOS, actualiza o vuelve a descargar la app, o por SSH:

   ```bash
   docker pull ghcr.io/iezappa/memini:latest
   ```

   y reinicia la app desde ZimaOS para que el contenedor se recree.
3. Al abrirse con conexión, el service worker descarga la versión nueva y
   Memini muestra **"Hay una versión nueva"**. **Actualizar** la recarga con esa versión.

Si la versión cambia el esquema de la base de datos (`update.json` dice
`"schemaChange": true`, como la 1.1.0), el aviso pide primero un backup y
la migración corre en cada dispositivo al abrir la app. Pide a todos que exporten
**antes** de publicarla.
