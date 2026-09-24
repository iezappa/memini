# Política de privacidad de Memini

[English](PRIVACY.md) · **Español**

Última actualización: 2026-09-17

Memini es una app gratuita desarrollada por Zeke Zappa Developments (iezappa). Esta política explica, en lenguaje simple, qué pasa con tus datos.

## Qué datos guarda la app

- Todo lo que registras en la app (salas de escape, comidas, conciertos, películas y series, juegos, puntuaciones y reseñas) se guarda **solo en tu dispositivo**.
- **No se guarda en ningún servidor**: ni en los del desarrollador ni en el servidor que entrega la versión web.
- El desarrollador **no puede ver, recuperar ni borrar** tus datos.
- No hay cuentas, ni analítica, ni publicidad.

## Almacenamiento en tu dispositivo

La app usa el almacenamiento de tu dispositivo o navegador (una base de datos local y, en la versión web, `localStorage`, IndexedDB, OPFS y la caché del service worker) **solo para funcionar**: guardar tus registros, tus ajustes y abrir sin conexión. No usa cookies de seguimiento.

Las claves de TMDB y RAWG que pegas en Ajustes se guardan en los ajustes locales de la app en este dispositivo, en texto plano (en el navegador, en `localStorage`). Solo se envían al servicio al que pertenecen.

## Conexiones a internet

La app funciona completa sin conexión. Solo se conecta en estos casos:

- **Búsquedas, solo cuando tocas el botón de búsqueda en un formulario.** El texto que escribiste en el cuadro de búsqueda se envía al servicio correspondiente para completar detalles:
  - películas y series: [TMDB](https://www.themoviedb.org/) (junto con tu propia clave de TMDB);
  - juegos: [RAWG](https://rawg.io/) (junto con tu propia clave de RAWG);
  - bandas y artistas: [MusicBrainz](https://musicbrainz.org/) (sin clave; la solicitud identifica a la app por su nombre).

  Esos servicios reciben el texto buscado, tu clave cuando corresponde y lo que lleva cualquier solicitud web (como tu dirección IP), y lo tratan según sus propias políticas de privacidad. **Nada más de lo que registraste — puntuaciones, reseñas, fechas, lugares ni ningún otro registro — se envía nunca.** Si no usas las búsquedas, no se hace ninguna solicitud de búsqueda — pero mirá las sugerencias más abajo, que se piden solas en cuanto hay una clave cargada.
- **Sugerencias en la pantalla de inicio, cuando tenés una clave cargada.** Si hay una clave de TMDB o de RAWG, abrir la pantalla de inicio le pregunta a ese servicio qué es popular esta semana y muestra una al azar. La solicitud lleva tu clave y lo que lleva cualquier solicitud web (como tu dirección IP), nunca nada de lo que registraste. Nada de lo que vuelve se guarda: desaparece al cerrar la app. Sin clave cargada no se pregunta nada, y el estante lo dice.
- **Portadas, cuando un registro tiene imagen.** Una película o serie completada desde TMDB guarda la *dirección* de su póster y de su fondo, y un juego completado desde RAWG guarda la de su portada — nunca la imagen, así que se pide a la máquina de imágenes de ese servicio (`image.tmdb.org`, `media.rawg.io`) cada vez que esa tarjeta o esa página están en pantalla. Esa solicitud no lleva ninguna clave ni ninguno de tus datos: solo lo que lleva cualquier solicitud web, como tu dirección IP. Un registro que escribiste a mano no tiene imagen y no pide nada.
- **Consulta de actualizaciones.** La app pregunta a GitHub (`api.github.com`) si hay una versión nueva, como máximo una vez cada seis horas; la versión web lee `version.json` del mismo sitio desde el que se cargó. Esa consulta no lleva ninguno de tus datos.

## Tus derechos y cómo borrar tus datos

- **Borrar todo:** Ajustes → Tus datos → **Borrar todos mis datos**. También se borran al desinstalar la app o al borrar los datos del sitio en el navegador.
- **Copia de tus datos:** Ajustes → Tus datos → **Exportar**.
- Como el desarrollador no tiene tus datos, no puede entregarlos ni borrarlos por ti.

## Menores

Memini no está dirigida a menores de 13 años.

## Cambios

Si esta política cambia, se actualiza la fecha de arriba y se menciona en las novedades de la app.

## Contacto

Zeke Zappa Developments (iezappa) — https://github.com/iezappa/memini/issues
