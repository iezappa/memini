# Setup — Cómo arrancar un proyecto nuevo con este stack

> **Cómo usar este archivo:** playbook a seguir cada vez que arrancas un proyecto nuevo de app dinámica multiplataforma (ver `STACK-APPS-DINAMICAS.md`). `Estandarizador/` se queda como referencia; el desarrollo real ocurre en un repo nuevo por proyecto.

## Fase 0 — Herramientas (una sola vez en tu máquina)

```bash
# Flutter (incluye Dart)
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:~/flutter/bin"
flutter doctor

# Habilitar los targets de escritorio/web que vas a usar
flutter config --enable-windows-desktop --enable-linux-desktop --enable-macos-desktop

# Node.js (vía nvm, para el backend)
nvm install --lts

# Docker (Postgres/Redis locales)
# En WSL: Docker Desktop con integración WSL, o Docker Engine nativo en Ubuntu

# CLI de Nest
npm install -g @nestjs/cli
```

`flutter doctor` te va a decir qué falta por SO (Android Studio/SDK para Android, Xcode solo si tienes Mac para iOS/macOS, Visual Studio con carga "Desktop development with C++" para Windows).

## Fase 1 — Crear el repo del proyecto

```bash
mkdir mi-proyecto && cd mi-proyecto
git init
```

Copia dentro `STACK-APPS-DINAMICAS.md` como referencia (o solo enlázalo mentalmente, no hace falta commitearlo si no quieres).

Estructura sugerida:

```
mi-proyecto/
├── apps/
│   ├── backend/      # NestJS
│   └── client/        # Flutter
└── packages/
    └── api-client/     # SDK Dart autogenerado desde OpenAPI
```

## Fase 2 — Backend primero (define el contrato)

```bash
cd apps
nest new backend
cd backend
npm install @nestjs/swagger prisma @prisma/client
npx prisma init   # crea prisma/schema.prisma + .env
```

- Levanta Postgres y Redis con un `docker-compose.yml` mínimo (dos servicios, volúmenes locales).
- Define tu primer modelo en `schema.prisma` y corre `npx prisma migrate dev`.
- Crea un módulo/controlador de ejemplo y decóralo con `@nestjs/swagger` para que `GET /api-json` exponga el spec OpenAPI.
- Levanta el server: `npm run start:dev` → confirma que `http://localhost:3000/api-json` responde.

**Por qué backend primero:** el spec OpenAPI que genera es lo que va a alimentar el cliente Flutter — sin endpoints no hay nada que generar.

## Fase 3 — Cliente Flutter

```bash
cd ../  # apps/
flutter create client --platforms=windows,linux,macos,web,android,ios
cd client
flutter pub add flutter_riverpod go_router
```

Corre algo ya para validar el entorno en al menos dos plataformas:

```bash
flutter run -d linux     # o windows/macos
flutter run -d chrome    # web
```

## Fase 4 — Generar el SDK del cliente desde OpenAPI

```bash
# con el backend corriendo en localhost:3000
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:3000/api-json \
  -g dart \
  -o ../../packages/api-client
```

Agrega ese paquete como dependencia local en `client/pubspec.yaml` (`path: ../../packages/api-client`). Cada vez que cambies un endpoint en Nest, re-corres este comando — nunca edites a mano los modelos generados.

## Fase 5 — Primer commit y CI

```bash
git add .
git commit -m "scaffold: backend NestJS + cliente Flutter + SDK generado"
```

Luego, cuando quieras automatizar: un workflow de GitHub Actions con dos jobs (backend: test+build imagen Docker; client: matriz de builds por plataforma). Se deja para cuando el proyecto tenga algo real que probar — no vale la pena antes.

## Fase 6 — Smartwatches (solo si el proyecto los necesita desde ya)

Se posponen hasta tener la API estable: son proyectos nativos aparte (`apps/wearos` con Android Studio, `apps/watchos` con Xcode) que consumen la misma API REST. No los arranques en el día 1 salvo que sea el foco del producto.
