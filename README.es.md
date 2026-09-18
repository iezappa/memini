# Memini

[English](README.md) · **Español**

[![CI](https://github.com/iezappa/memini/actions/workflows/ci.yml/badge.svg)](https://github.com/iezappa/memini/actions/workflows/ci.yml)

Un registro personal de lo que realmente hiciste —escape rooms, comidas fuera,
conciertos, películas y series, y juegos—, cada cosa con una puntuación y tu propia reseña.

- **Descargas:** https://github.com/iezappa/memini/releases/latest
- **Versión web (iPhone, iPad y cualquier navegador):** https://iezappa.github.io/memini/

> [!WARNING]
> **Tus datos viven SOLO en tu dispositivo.**
>
> - No se guardan en los servidores del desarrollador ni en ningún servidor que entregue la versión web: esos solo reparten la app.
> - Si desinstalas la app, pierdes o reseteas el dispositivo, o borras los datos del navegador o de Safari, **tus datos se pierden para siempre**.
> - La única copia de seguridad es la que hagas tú.
>
> **Haz un backup con frecuencia (una vez por semana es un buen hábito):**
>
> 1. Abre la app → **Ajustes** → **Tus datos** → **Exportar backup (JSON)**.
> 2. Guarda el archivo `.json` en un lugar **fuera de este dispositivo**: iCloud Drive, Google Drive, OneDrive, un correo a ti mismo u otro dispositivo.
>
> **Para recuperar tus datos** (dispositivo nuevo, reinstalación):
>
> 1. Instala la app y ábrela.
> 2. **Ajustes** → **Tus datos** → **Importar backup** → elige tu último archivo `.json`.
> 3. Confirma. Lo que hay en el archivo reemplaza lo que hay en la app.

## Índice

- [Servidor propio (ZimaOS)](#servidor-propio-zimaos)
- [Windows](#windows)
- [Ubuntu (Linux)](#ubuntu-linux)
- [macOS](#macos)
- [iPhone y iPad](#iphone-y-ipad)
- [Android](#android)
- [Actualizaciones](#actualizaciones)
- [Privacidad](#privacidad)
- [Para desarrolladores](#para-desarrolladores)

---

## Servidor propio (ZimaOS)

Solo lo necesita **quien administra el servidor**; el resto salta a su dispositivo.

El servidor publica la versión web para que la familia la use en un navegador o la instale como app (PWA). En resumen:

1. Un tag de versión (`vX.Y.Z`) hace que GitHub construya `ghcr.io/iezappa/memini`. La primera vez, haz público el paquete en GitHub.
2. Importa `deploy/docker-compose.yml` (ya completo; puerto 8082) en ZimaOS: **App Store** → **+** → **Install a customized app** → **Import**.
3. Instala **Tailscale** en ZimaOS, habilita HTTPS y expón la app con `tailscale serve`. Queda en `https://<servidor>.<tailnet>.ts.net/`.
4. Cada persona instala Tailscale en su dispositivo y se une a la tailnet.

**Guía completa:** [`deploy/ZIMAOS.es.md`](deploy/ZIMAOS.es.md), que explica también por qué las búsquedas siguen funcionando detrás de las cabeceras de aislamiento del contenedor.

**Tus datos:** actualizar, reinstalar o eliminar el contenedor **no** toca los datos de nadie, porque ninguno está en el servidor. Usa siempre **la misma URL**, también en casa: a través de la IP de la red local el navegador ve otro sitio y la app aparece vacía.

---

## Windows

**Requisitos:** Windows 10 u 11 de 64 bits.

**Instalar:**

1. Entra a https://github.com/iezappa/memini/releases/latest.
2. En **Assets**, descarga `memini-vX.Y.Z-windows-x64.zip`.
3. Clic derecho sobre el `.zip` → **Extraer todo** → elige una carpeta fija, como `Documentos\Memini`. No lo ejecutes desde dentro del `.zip`.
4. Abre la carpeta y haz doble clic en `memini.exe`.
5. Windows muestra **"Windows protegió su PC"** porque la app no está firmada. Haz clic en **Más información** → **Ejecutar de todas formas**. Solo la primera vez.

> Deja los demás archivos junto al `.exe` (archivos `.dll`, la carpeta `data`): los necesita.

**Actualizar:** haz un backup (**Ajustes → Tus datos → Exportar backup (JSON)**), cierra la app y extrae el `.zip` nuevo **en la misma carpeta**, reemplazando los archivos.

**Tus datos:** se guardan en tu perfil de usuario de Windows, fuera de la carpeta de la app, así que reemplazar la carpeta no los borra. Formatear el equipo o cambiar de usuario de Windows sí.

---

## Ubuntu (Linux)

**Requisitos:** Ubuntu 22.04 o posterior, de 64 bits (x86_64). No hay compilación para ARM.

**Instalar:**

1. Bibliotecas del sistema, una sola vez (`libsecret` guarda el PIN):

   ```bash
   sudo apt update
   sudo apt install libgtk-3-0 libsecret-1-0
   ```

2. Descarga `memini-vX.Y.Z-linux-x64.tar.gz` desde https://github.com/iezappa/memini/releases/latest.
3. Extráelo en una carpeta fija y ejecútalo:

   ```bash
   mkdir -p ~/Apps/memini
   tar -xzf ~/Downloads/memini-vX.Y.Z-linux-x64.tar.gz -C ~/Apps/memini
   ~/Apps/memini/memini
   ```

**Actualizar:** haz un backup, cierra la app, vacía `~/Apps/memini` y extrae ahí el `.tar.gz` nuevo.

**Tus datos:** se guardan dentro de tu carpeta personal (normalmente en `~/.local/share/`), no en `~/Apps/memini`. Reinstalar Ubuntu o borrar tu carpeta personal los borra.

---

## macOS

**Requisitos:** un Mac con macOS reciente (Intel o Apple Silicon).

**Instalar:**

1. Descarga `memini-vX.Y.Z-macos.zip` desde https://github.com/iezappa/memini/releases/latest.
2. Haz doble clic en el `.zip` y arrastra la app a **Aplicaciones**.
3. La app no está firmada, así que macOS la bloquea la primera vez: **clic derecho** (o Control + clic) → **Abrir** → **Abrir**. Si no aparece esa opción, intenta abrirla y luego ve a **Ajustes del Sistema** → **Privacidad y seguridad** → **Abrir igualmente**.
4. Si macOS dice que la app **"está dañada"**, ejecuta en **Terminal**:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/memini.app"
   ```

**Actualizar:** haz un backup, cierra la app, reemplázala en **Aplicaciones** por la nueva y repite el paso 3 si hace falta.

**Tus datos:** se guardan en tu usuario de macOS (dentro de `~/Library`), no dentro de la app. Borrar tu usuario o resetear el Mac los borra.

---

## iPhone y iPad

No hay versión en App Store. Se usa la **versión web agregada a la pantalla de inicio**, que se comporta como una app. **Funciona sin conexión después de abrirla una vez con conexión** (ciérrala y vuelve a abrirla antes de probar sin conexión).

**Requisitos:** iOS o iPadOS 17 o posterior (recomendado), **Safari**.

**Instalar:**

1. Abre **Safari** (tiene que ser Safari).
2. Entra a https://iezappa.github.io/memini/.
3. Toca **Compartir** (el cuadrado con una flecha).
4. Toca **Agregar a inicio** → **Agregar**.
5. **Abre Memini siempre desde ese ícono**, nunca desde una pestaña de Safari.

> El ícono y una pestaña de Safari guardan datos por separado. Además, Safari puede borrar los datos de sitios que no usas durante días; un ícono que usas con regularidad no se borra de esa forma.

**Actualizar:** abre la app con conexión; cuando aparezca **"Hay una versión nueva"**, toca **Actualizar**. Si no aparece, cierra la app por completo y vuelve a abrirla.

**Tus datos:** se guardan solo en este iPhone o iPad, dentro de la app del ícono. Quitar el ícono, borrar los datos de sitios web en **Ajustes → Safari** o resetear el dispositivo los borra. Quitar el ícono equivale a desinstalar: **exporta antes**.

---

## Android

Dos opciones. Elige **una** y quédate con ella: el APK y la app de Chrome guardan datos por separado. Para cambiar, exporta en la vieja e importa en la nueva.

### Opción 1: APK (recomendada; no necesita servidor ni conexión)

**Requisitos:** Android 7 o posterior (recomendado).

**Instalar:**

1. En el teléfono, abre https://github.com/iezappa/memini/releases/latest.
2. En **Assets**, descarga `memini-vX.Y.Z-android.apk`. Se adjunta a mano poco después de crear cada versión; si todavía no está, vuelve a mirar más tarde.
3. Abre el archivo descargado. Permite instalar desde este origen cuando Android lo pida.
4. Toca **Instalar**. Si Google Play Protect muestra un aviso, elige **Instalar de todas formas**.

**Actualizar:** con conexión, Memini muestra **"Hay una versión nueva"**. Toca **Descargar**, haz un backup si el aviso lo pide e instala el APK encima de la app existente. **No desinstales primero**: desinstalar borra tus datos. Todas las versiones van firmadas con la misma clave, así que se instalan encima; si Android alguna vez informa de un conflicto, **no desinstales**: exporta tus datos y abre un issue.

**Actualizaciones automáticas (opcional) con Obtainium:** instala Obtainium (https://github.com/ImranR98/Obtainium/releases o F-Droid), toca **Agregar app**, pega `https://github.com/iezappa/memini` y toca **Agregar**.

**Tus datos:** se guardan dentro de la app. Desinstalarla, **Borrar almacenamiento** en sus ajustes o resetear el teléfono los borra.

### Opción 2: instalar desde Chrome (PWA)

1. Abre **Chrome** en https://iezappa.github.io/memini/.
2. Menú **⋮** → **Instalar app**.
3. Ábrela desde su ícono, siempre desde la misma URL.

Funciona sin conexión después de abrirla una vez con conexión. **Actualiza** con el aviso dentro de la app. **Tus datos** los guarda Chrome para esa URL.

---

## Actualizaciones

Memini busca una versión nueva cuando se abre con conexión, y otra vez cuando vuelve al primer plano (en escritorio y en el APK, como mucho cada 6 horas). Sin conexión no cambia nada.

| Dispositivo | Cómo te enteras | Cómo actualizas |
|---|---|---|
| iPhone y iPad | "Hay una versión nueva" | Toca **Actualizar**. |
| Android (APK) | "Hay una versión nueva" | **Descargar** e instalar encima, u Obtainium. |
| Android (Chrome) y navegadores | "Hay una versión nueva" | Toca **Actualizar**. |
| Windows, Ubuntu, macOS | "Hay una versión nueva" | **Descargar** abre la página de la versión; sigue los pasos de **Actualizar** de tu sistema. |

- **Si el aviso pide un backup**, la versión nueva cambia cómo se guardan los datos (la 1.1.0 lo hace): toca **Exportar** y guarda el archivo **antes** de actualizar.
- Después de una actualización, Memini muestra las **Novedades** de esa versión. El historial completo está en **Ajustes → Acerca de → Versión**.

---

## Privacidad

Memini no tiene cuentas, analítica ni publicidad. Lo que registras se queda en tu dispositivo. Solo se conecta a internet en dos casos:

- **Búsquedas**, y solo cuando tocas el botón de búsqueda en un formulario: el texto que escribiste en el cuadro de búsqueda va a TMDB (películas y series, con tu propia clave de TMDB), RAWG (juegos, con tu propia clave de RAWG) o MusicBrainz (bandas, sin clave). No se envía nada más de lo que registraste. Las claves que pegas se guardan en los ajustes locales de la app, en texto plano.
- **La comprobación de actualizaciones**: la API de versiones de GitHub en escritorio y Android, y el propio `version.json` del sitio en la web. No lleva ninguno de tus datos.

Para borrarlo todo: **Ajustes → Tus datos → Borrar todos mis datos**.

- [Política de privacidad](PRIVACY.es.md)
- [Términos de uso](TERMS.es.md)
- English: [Privacy policy](PRIVACY.md) · [Terms of use](TERMS.md)

Desarrollador: Zeke Zappa Developments (iezappa) — preguntas y reportes en https://github.com/iezappa/memini/issues

---

## Para desarrolladores

Memini sigue `STACK-APPS-DINAMICAS.md` (perfil A) del estándar Estandarizador.
El proyecto Flutter está en `apps/client`.

```bash
cd apps/client
flutter pub get
dart run build_runner build      # código generado de Drift
flutter test
bash tool/generate_sw_test.sh
flutter run -d chrome            # o linux / windows / macos / un dispositivo Android
```

Probar la imagen web localmente:

```bash
docker build -f deploy/Dockerfile -t memini .
docker run --rm -p 8080:8080 memini    # http://localhost:8080
```

**Publicar una versión** (detalles en [`docs/RELEASING.md`](docs/RELEASING.md)):

```bash
# pubspec.yaml (x.y.z+build), web/update.json y assets/release_notes/*.json
# deben nombrar la versión del tag; si no, release.yml rechaza el tag.
git tag vX.Y.Z && git push origin vX.Y.Z
```

`release.yml` construye `memini-vX.Y.Z-linux-x64.tar.gz`, `-windows-x64.zip`,
`-macos.zip` y `-web.zip`, adjunta `update.json` y sube
`ghcr.io/iezappa/memini`. GitHub Pages se publica desde `master` con
`pages.yml`. El APK no se compila en CI: el mantenedor lo firma en local con
el keystore de release y sube `memini-vX.Y.Z-android.apk` junto con su `.sha256`
con `tool/release_apk.sh vX.Y.Z` (desde `apps/client`). La huella esperada del
certificado está en [`docs/SIGNING.md`](docs/SIGNING.md), todavía
pendiente hasta que se cree el keystore.

La compilación web trae su propio service worker (`web/sw.js`, registrado por
`web/flutter_bootstrap.js`); CI, Pages y el Dockerfile ejecutan
`tool/generate_sw.sh` después de `flutter build web`. Si una versión rompe el
service worker, publica el kill switch (`web/sw-killswitch.js`, instrucciones dentro).

Cuando una versión cambia el esquema de Drift: sube `schemaVersion`, vuelca el esquema,
agrega el test de migración y marca `"schemaChange": true` en `web/update.json` para que
el aviso de actualización pida primero un backup.

### Stack

Flutter local-first, siguiendo `Estandarización/STACK-APPS-DINAMICAS.md` en
todo lo que aplica y descartando a propósito las partes que suponen un
backend.

| Capa | Elección |
|---|---|
| UI | Flutter (Linux, Web, Android) · Material 3 con un tema propio |
| Estado | Riverpod |
| Navegación | go_router |
| Almacenamiento | Drift (SQLite) detrás de repositorios de dominio |
| Preferencias | shared_preferences · hash del PIN en flutter_secure_storage |
| Búsquedas | TMDB, RAWG y MusicBrainz, con las claves propias del usuario |

**No hay backend**. NestJS, PostgreSQL, Redis, Keycloak y el SDK generado con
OpenAPI quedan fuera: un registro offline de un solo usuario no tiene
nada que darles. Docker solo sirve la compilación web (`deploy/`). Más adelante se puede agregar una fuente de datos remota detrás de los
puertos de repositorio existentes sin tocar el dominio.

### Patrones de producto estándar

Los cinco patrones de la sección 2.1 del estándar de stack, más los enlaces
de apoyo de la sección 9:

- **i18n** — `flutter_localizations` + archivos ARB, español e inglés.
- **Onboarding** — tres pantallas en el primer inicio, que se pueden volver a abrir desde Ajustes.
- **Aviso legal** — aceptación explícita en el primer inicio, siempre visible en Ajustes.
- **Bloqueo con PIN** — SHA-256 con sal en almacenamiento seguro, sin una vía solo biométrica.
- **Importar / exportar** — JSON es la fuente de verdad, CSV para hojas de cálculo.
- **Enlaces de apoyo** — Cafecito y Patreon, siempre uno junto al otro.

### Estructura

```
apps/client/lib/
├── app/            # providers, router, MaterialApp
├── core/
│   ├── database/   # agrega las tablas de todas las features
│   ├── enrichment/ # búsquedas en TMDB / RAWG / MusicBrainz
│   ├── theme/
│   └── tracking/   # la columna vertebral común: Trackable, filtros, puerto del repo, UI compartida
├── features/
│   ├── rooms/      # domain / data / presentation
│   ├── dining/
│   ├── concerts/
│   ├── screen/
│   ├── games/
│   ├── franchises/
│   ├── stats/
│   ├── backup/
│   ├── security/
│   ├── onboarding/
│   ├── settings/
│   └── shared/
└── l10n/
```

Cada feature es dueña de sus tablas de Drift, de su puerto de dominio y del adaptador que
lo implementa. `core/database/app_database.dart` solo agrega las tablas.

`core/tracking/` es lo que evita que cinco dominios sean cinco copias: la
interfaz `Trackable`, `TrackingFilter` y su orden, el
`TrackingRepository` genérico, el mixin de columnas de Drift y el SQL compartido de búsqueda y orden,
además de los widgets de lista, tarjeta, detalle y formulario que reutiliza cada dominio.

### Ejecutar

```bash
cd apps/client
flutter run -d linux    # o: -d chrome, -d <dispositivo android>
flutter test
```

El escritorio de Linux necesita `libsecret-1-dev` para el plugin del bloqueo con PIN:

```bash
sudo apt-get install -y libsecret-1-dev libjsoncpp-dev
```

### Modelo de datos

Cada entrada comparte su id (un UUID), título, descripción, puntuación (0–10),
reseña, la fecha en que ocurrió y cuándo se modificó por última vez (`updatedAt`), y
luego agrega los suyos:

| Dominio | Entidad | Campos propios |
|---|---|---|
| Escape rooms | `Room` | si se escapó, minutos restantes, franquicia |
| Comidas | `Meal` | plato, precio, compañía, lugar |
| Conciertos | `Gig` | sala, ciudad, teloneros, setlist, compañía |
| Pantalla | `Viewing` | tipo (película/serie/miniserie/documental), año de estreno, director, reparto, temporada |
| Juegos | `Game` | estado (jugando/terminado/100%/abandonado), plataforma, horas jugadas, año de lanzamiento |

```
Franchise ──< Room
```

Borrar una franquicia desvincula sus salas en lugar de borrarlas.

La base de datos está en el esquema v4 (`drift_schemas/`, con un test de migración desde
cada versión anterior). Los backups usan el formato JSON v3; los archivos v1 y v2 todavía
se importan, con UUID nuevos y sus vínculos reasignados.

### Búsquedas

Películas, series, juegos y conciertos se pueden completar desde una fuente externa
en lugar de a mano. TMDB y RAWG necesitan una clave de API personal, que se pega en Ajustes
y nunca se incluye en la app; MusicBrainz no necesita ninguna. Cada búsqueda es
opcional: el formulario funciona completamente sin conexión y sin clave.
