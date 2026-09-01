# Stack Tecnológico — Sitios y Aplicaciones Estáticas

> **Cómo usar este archivo:** pégalo en la raíz de cada proyecto que sea un sitio web estático o mayormente estático (landing pages, sitios de contenido/marketing, blogs, documentación, portafolios) — es decir, sin backend propio con lógica de negocio ni base de datos relacional persistente.

## 1. Principio rector

Cero servidor que mantener. HTML generado en build time, JavaScript mínimo, despliegue en CDN. Si el proyecto empieza a necesitar lógica de negocio, estado persistente o autenticación de usuarios reales, ha dejado de ser "estático": migra a la plantilla `STACK-APPS-DINAMICAS.md`.

## 2. Framework y estilos

| Capa | Elección | Por qué |
|---|---|---|
| Generador de sitio | **Astro** | *Islands architecture*: cero JS por defecto, solo hidrata los componentes interactivos que declares. Mejor rendimiento y SEO que un SPA completo para contenido mayormente estático. |
| Componentes interactivos (islas) | React o Vue dentro de Astro, según preferencia — usar **uno solo** por proyecto | Astro permite mezclar frameworks; estandariza a uno para no fragmentar el conocimiento del equipo. |
| Estilos | **Tailwind CSS** | Mismo sistema de diseño reutilizable entre proyectos estáticos y, si aplica, entre el Web build de Flutter (vía tokens de diseño compartidos). |
| Contenido | **Markdown/MDX** con *Content Collections* de Astro | Contenido versionado en git, tipado, sin necesidad de un CMS para la mayoría de casos. |
| CMS (solo si el cliente no técnico edita contenido) | **Directus** (self-hosted, headless) o un CMS *git-based* (Decap CMS) | Evita añadir un CMS si nadie no-técnico va a usarlo — es complejidad innecesaria. |

## 3. PWA (instalabilidad)

Todo sitio de esta plantilla se entrega como PWA instalable por defecto — es la forma de simplificar la instalación sin pasar por una tienda de apps.

| Capa | Elección | Por qué |
|---|---|---|
| Integración | **`@vite-pwa/astro`** | Zero-config: inyecta el Web App Manifest y genera el service worker (Workbox) a partir de la config de Astro, sin escribirlo a mano. |
| Estrategia de service worker | `generateSW` (default) | Cubre el caso común — precache de los assets del build. Usa `injectManifest` solo si el proyecto necesita lógica de caché a medida (ej. rutas dinámicas con datos que cambian). |
| Manifest | `name`, `short_name`, `theme_color`, `background_color`, `display: 'standalone'`, íconos 192x192 y 512x512 (+ variante `maskable`) | Es el mínimo que exigen Chrome/Edge/Android para ofrecer el prompt de instalación nativo. |
| Actualización | `registerType: 'autoUpdate'`, salvo que el proyecto necesite confirmar la actualización con el usuario (`prompt`) | Evita que un usuario quede atascado en una versión vieja del sitio cacheada por el service worker. |

## 4. Interactividad ligera sin backend propio

- Formularios de contacto: **Cloudflare Workers** o el proveedor de hosting (funciones serverless) — no levantes un backend NestJS completo para esto.
- Analítica: **Plausible** o **Umami** (privacidad-first, sin cookies de tracking pesado) en vez de Google Analytics por defecto.
- Búsqueda en sitio: **Pagefind** (indexa en build time, cero servidor).

## 5. Despliegue

| Capa | Elección | Por qué |
|---|---|---|
| Hosting | **Cloudflare Pages** (default) o Netlify/Vercel como alternativas | CDN global, despliegue por git push, rollback instantáneo, capa gratuita generosa. |
| CI/CD | Integración nativa del proveedor de hosting con GitHub (build automático en cada push/PR) — sin pipeline propio salvo necesidades particulares. |
| Dominio/DNS | Cloudflare DNS si el hosting es Cloudflare Pages, para mantener todo bajo el mismo panel. |

## 6. Checklist mínimo de calidad antes de publicar

- [ ] Lighthouse: Performance, Accessibility, Best Practices y SEO todos en verde (>90).
- [ ] `sitemap.xml` y `robots.txt` generados.
- [ ] Meta tags Open Graph / Twitter Card en todas las páginas relevantes.
- [ ] Imágenes optimizadas (formato `webp`/`avif`, `astro:assets`).
- [ ] Modo oscuro/claro si el diseño lo contempla (coherencia con el resto de proyectos).
- [ ] Lighthouse → categoría "Installable" en verde.
- [ ] `manifest.webmanifest` válido, íconos correctos y service worker registrado sin errores en consola.
- [ ] Prueba real de instalación en al menos Chrome desktop y Android.

## 7. Cuándo migrar de esta plantilla a `STACK-APPS-DINAMICAS.md`

Migra en cuanto aparezca cualquiera de estos requisitos:
- Autenticación de usuarios con datos persistentes por usuario.
- Lógica de negocio que no puede vivir en una función serverless simple.
- Necesidad de una base de datos relacional propia.
- El sitio necesita convertirse en app instalable multiplataforma más allá de lo que cubre la PWA de la sección 3 (ej. acceso a APIs nativas del SO, distribución en tiendas de apps, soporte desktop/mobile nativo real).
