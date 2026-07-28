# Lista de publicación del portafolio

Esta lista se utiliza para publicar la versión reconstruida del portafolio sin reemplazar `main` antes de terminar las validaciones.

## 1. Revisión local

Desde `redesign-2026`:

```powershell
git switch redesign-2026
git pull origin redesign-2026
git status
```

Ejecutar la auditoría completa:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release_check.ps1
```

Durante una revisión previa con archivos todavía sin confirmar puede utilizarse:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release_check.ps1 -AllowDirty
```

Docker solo debe omitirse cuando no esté disponible:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release_check.ps1 -SkipDocker
```

La publicación no debe continuar mientras el informe muestre errores.

## 2. Revisión visual

Comprobar en computadora y vista móvil:

- `/` y `/en/`.
- Navegación, selector de idioma y tema claro/oscuro.
- Perfil, experiencia, proyectos, habilidades y contacto.
- ProtectPYME, NetAdmin API y videojuegos.
- Descarga de los dos PDF.
- Contraste, foco visible y navegación con teclado.
- Ausencia de datos privados, credenciales y capturas sensibles.

## 3. Guardar la Parte 8

```powershell
git add RELEASE_CHECKLIST.md CHANGELOG.md SECURITY.md scripts/release_check.ps1
git commit -m "Agrega auditoria y documentacion de publicacion"
git push origin redesign-2026
```

Después del `push`, volver a ejecutar la auditoría sin `-AllowDirty`.

## 4. Crear el pull request

Base: `main`  
Compare: `redesign-2026`

Título recomendado:

```text
Rediseña el portafolio profesional bilingüe
```

Descripción recomendada:

```markdown
## Resumen

- Reconstruye el portafolio con Hugo y plantillas propias.
- Agrega versiones en español e inglés.
- Presenta experiencia, formación, habilidades y proyectos técnicos.
- Incorpora CV y résumé descargables.
- Agrega Docker, Docker Compose, Nginx, SEO y accesibilidad.
- Configura validación y despliegue con GitHub Actions.

## Validaciones

- [x] Compilación de producción con Hugo.
- [x] Validación de enlaces, metadatos y archivos.
- [x] Revisión visual en computadora y celular.
- [x] Prueba de Docker y health check, cuando está disponible.
- [x] Sin datos privados ni secretos detectados.
```

Esperar a que el trabajo `build` aparezca en verde.

## 5. Configurar GitHub Pages

En el repositorio:

1. Abrir **Settings**.
2. Entrar a **Pages**.
3. En **Build and deployment**, seleccionar **Source: GitHub Actions**.

No seleccionar una carpeta `docs` ni publicar desde una rama porque el repositorio ya contiene un flujo personalizado.

## 6. Integrar el pull request

Usar preferentemente **Squash and merge** para dejar un único commit de rediseño en `main`.

Mensaje recomendado:

```text
Publica portafolio profesional bilingüe
```

No utilizar `git push --force` sobre `main`.

## 7. Comprobar el despliegue

Después del merge, revisar **Actions** y esperar que finalicen en verde los trabajos `build` y `deploy`.

Comprobar públicamente:

- `https://dkrxchelita13.github.io/`
- `https://dkrxchelita13.github.io/en/`
- `https://dkrxchelita13.github.io/projects/`
- `https://dkrxchelita13.github.io/projects/protectpyme/`
- `https://dkrxchelita13.github.io/projects/netadmin-api/`
- `https://dkrxchelita13.github.io/files/CV_Luz_Graciela_Torales_ES.pdf`
- `https://dkrxchelita13.github.io/files/Luz_Graciela_Torales_Resume_EN.pdf`
- `https://dkrxchelita13.github.io/robots.txt`
- `https://dkrxchelita13.github.io/sitemap.xml`

Probar en una ventana privada para evitar una versión anterior almacenada en caché.

## 8. Crear la versión estable

Cuando la página pública funcione correctamente:

```powershell
git switch main
git pull --ff-only origin main
git tag -a portfolio-v2.0.0 -m "Portafolio profesional bilingüe v2.0.0"
git push origin portfolio-v2.0.0
```

La etiqueta `portfolio-v1-2026-07-27` conserva la referencia a la versión anterior.

## 9. Proteger `main`

Después de que el flujo haya aparecido al menos una vez:

1. Abrir **Settings → Branches** o **Settings → Rules → Rulesets**.
2. Crear una regla para `main`.
3. Requerir un pull request antes de integrar cambios.
4. Requerir que el control `build` termine correctamente.
5. Bloquear force pushes y eliminación de la rama.

En un repositorio personal no conviene exigir una aprobación de otra persona si no hay un colaborador disponible, porque bloquearía tus propios pull requests.

## 10. Limpieza opcional

Después de confirmar la versión pública y la etiqueta:

```powershell
git branch -d redesign-2026
git push origin --delete redesign-2026
```

También puede conservarse la rama durante algunos días antes de eliminarla.

## Reversión segura

Si el despliegue nuevo presenta un problema importante, no reescribir el historial. Revertir el commit del merge desde GitHub o con:

```powershell
git switch main
git pull --ff-only origin main
git log --oneline -5
git revert <HASH_DEL_COMMIT_DE_PUBLICACION>
git push origin main
```

El flujo volverá a publicar automáticamente el estado anterior.
