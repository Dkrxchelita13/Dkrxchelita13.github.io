# Portafolio profesional de Luz Graciela Torales Rodríguez

Sitio bilingüe creado con Hugo para presentar experiencia, proyectos, formación y habilidades en ciberseguridad, redes, desarrollo backend y automatización.

## Requisitos

- Hugo Extended 0.164.0 o compatible.
- Git.
- Docker Desktop y Docker Compose, opcionales para la ejecución contenerizada.
- Python 3, utilizado por la validación local del sitio generado.

## Desarrollo local con Hugo

```powershell
hugo server -D
```

Abrir `http://localhost:1313/`.

## Compilación de producción

```powershell
hugo --gc --minify --cleanDestinationDir
python scripts/validate_site.py public
```

La carpeta `public/` se genera localmente y no se almacena en Git.

## Ejecución con Docker Compose

```powershell
docker compose up --build -d
```

Abrir `http://localhost:8080/`.

Consultar estado:

```powershell
docker compose ps
docker compose logs -f portfolio
```

Detener y eliminar el contenedor:

```powershell
docker compose down
```

## Despliegue

El flujo `.github/workflows/deploy.yml` realiza tres tareas:

1. Compila y valida cada actualización de `redesign-2026` y cada pull request dirigido a `main`.
2. Comprueba la configuración de Docker Compose.
3. Publica en GitHub Pages únicamente cuando el cambio llega a `main`.

Antes del primer despliegue, en GitHub debe seleccionarse **Settings → Pages → Source → GitHub Actions**.

## SEO y calidad

El sitio incluye:

- URL canónica y etiquetas `hreflang` para español e inglés.
- Open Graph y Twitter Cards con imágenes de 1200 × 630.
- Datos estructurados JSON-LD para la persona y los casos de proyecto.
- `robots.txt`, `sitemap.xml` y manifiesto web.
- CSS y JavaScript minificados, versionados mediante huella digital.
- Navegación con teclado, enlace para saltar contenido, foco visible y respeto a `prefers-reduced-motion`.
- Validación automática de títulos, descripciones, enlaces locales, fragmentos, imágenes y archivos obligatorios.

## Estructura principal

- `content/`: contenido en español e inglés.
- `layouts/`: plantillas Hugo propias.
- `assets/`: estilos, JavaScript e imágenes procesadas por Hugo.
- `static/`: documentos, iconos e imágenes públicas.
- `scripts/`: validaciones de calidad.
- `.github/workflows/`: integración y despliegue continuo.
- `Dockerfile`, `docker-compose.yml` y `nginx.conf`: ejecución contenerizada.
