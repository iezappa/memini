# Estandarizador

Fuente única de verdad para las decisiones de stack tecnológico que se replican en todos los proyectos nuevos. No son reglas rígidas: se actualizan aquí cuando cambie una decisión, y el cambio se propaga copiando el archivo actualizado a los proyectos activos.

## Archivos

- **`STACK-APPS-DINAMICAS.md`** — pegar en proyectos con backend, base de datos y/o lógica de negocio que corran en Windows, Ubuntu, Web, iOS, macOS, tablets, smartwatches y/o Android.
- **`STACK-SITIOS-ESTATICOS.md`** — pegar en sitios/páginas estáticas o mayormente estáticas (landing, blog, documentación, portafolio) sin backend propio.
- **`SETUP.md`** — playbook paso a paso para arrancar un proyecto nuevo de app dinámica: herramientas, scaffold de backend/cliente, generación del SDK y primer commit.

## Regla de oro

Un proyecto usa **una sola** de las dos plantillas, nunca ambas. Si un proyecto estático crece hasta necesitar backend/DB/auth propia, migra siguiendo la sección "Cuándo migrar" del archivo estático.

## Mantenimiento

Cuando se decida cambiar una pieza del stack (ej. cambiar de NestJS a otro framework), edita el `.md` correspondiente aquí primero, documenta el motivo, y luego actualiza manualmente los proyectos que quieran adoptar el cambio — esto no es un paquete instalable, es documentación de referencia.
