---
title: "NetAdmin API"
description: "API REST para inventario, escaneo, monitoreo y administración remota de dispositivos de red."
translationKey: "netadmin-api"
weight: 20
featured: true
status: "Funcional · en mejora continua"
category: "Backend + Redes"
year: "2026"
period: "2026"
role: "Desarrolladora backend y automatización de redes"
focus: "Inventario, monitoreo y administración segura"
project_type: "Proyecto académico"
cover: "images/projects/netadmin-cover.svg"
cover_alt: "Ilustración de NetAdmin API con dispositivos de red, una terminal y conexiones entre nodos"
github_url: "https://github.com/Dkrxchelita13/netadmin_api"
stack:
  - "Python"
  - "FastAPI"
  - "SQLite"
  - "Netmiko"
  - "Paramiko"
  - "Nmap"
  - "JWT / tokens"
  - "Pytest"
  - "HTML & CSS"
  - "Telegram API"
responsibilities:
  - "Diseño de endpoints CRUD y escaneo"
  - "Persistencia e histórico de cambios"
  - "Autenticación y control de roles"
  - "Automatización con Netmiko y Paramiko"
  - "Dashboard, reportes y alertas"
  - "Pruebas y documentación"
key_outputs:
  - "API REST documentada"
  - "Inventario persistente en SQLite"
  - "Ejecución remota controlada"
  - "Dashboard y escaneo programado"
  - "Reportes PDF y alertas"
card_points:
  - "Inventario y escaneo de dispositivos"
  - "Administración remota con Netmiko y Paramiko"
  - "Autenticación, histórico, reportes y alertas"
---

## Resumen

NetAdmin API es una solución desarrollada para centralizar tareas de inventario, descubrimiento, monitoreo y administración de dispositivos de red. El proyecto comenzó como una API REST y evolucionó para incorporar persistencia, autenticación, histórico de cambios, dashboard, reportes y alertas.

El objetivo técnico es reducir tareas manuales repetitivas y proporcionar una base organizada para consultar dispositivos, registrar modificaciones y ejecutar acciones remotas de forma controlada.

## Funcionalidades principales

- Registro, consulta, actualización y eliminación de dispositivos mediante endpoints CRUD.
- Búsqueda de dispositivos por dirección IP.
- Escaneo de redes en formato CIDR para detectar equipos activos.
- Exportación del inventario en formatos JSON, YAML y XML.
- Persistencia local mediante SQLite.
- Registro histórico de altas, actualizaciones y eliminaciones.
- Comparación entre configuraciones actuales y anteriores.
- Autenticación mediante tokens y separación de permisos entre roles de administración y consulta.
- Ejecución de comandos en switches Cisco mediante Netmiko.
- Administración de servidores Linux mediante Paramiko/SSH.
- Dashboard web para visualizar métricas del inventario.
- Escaneos automáticos programados.
- Generación de reportes PDF.
- Alertas mediante Telegram y correo electrónico.
- Pruebas automatizadas con Pytest.

## Arquitectura y módulos

```text
Cliente / Swagger / Dashboard
            │
            ▼
        FastAPI
            │
   ┌────────┼───────────┐
   ▼        ▼           ▼
Inventario  Seguridad   Automatización
SQLite      Tokens      Netmiko / Paramiko
   │                    │
   ▼                    ▼
Histórico            Switches Cisco
Reportes             Servidores Linux
Alertas
```

La aplicación separa responsabilidades en módulos para autenticación, acceso a base de datos, inventario, escaneo, exportación y administración remota. Esta separación facilita probar cada componente y agregar nuevas funciones sin concentrar toda la lógica en un solo archivo.

## Seguridad y control de acceso

El sistema diferencia dos perfiles principales:

- **Administrador:** puede registrar, modificar y eliminar dispositivos, ejecutar escaneos y utilizar funciones de administración remota.
- **Consulta:** puede autenticarse y revisar la información permitida sin modificar el inventario.

Las rutas protegidas validan el token y el rol antes de ejecutar la operación. Las contraseñas no se almacenan en texto plano y los errores de autenticación utilizan respuestas HTTP específicas.

## Automatización de redes

Netmiko se utiliza para trabajar con dispositivos de red compatibles mediante SSH, mientras que Paramiko permite establecer sesiones con servidores Linux. Las operaciones se exponen mediante endpoints protegidos y están pensadas para ejecutarse dentro de un entorno autorizado.

El escaneo de redes utiliza rangos CIDR. Durante las pruebas, los rangos reducidos permitieron validar el descubrimiento sin realizar búsquedas innecesariamente amplias.

## Persistencia, seguimiento y alertas

SQLite guarda el inventario y el histórico de modificaciones. Cada cambio puede registrar la acción, la dirección IP, los datos anteriores, los datos nuevos y la fecha. Esto permite auditar la evolución del inventario y comparar configuraciones.

Los reportes PDF consolidan los resultados relevantes, mientras que las alertas permiten informar eventos mediante Telegram o correo electrónico.

## Calidad y documentación

- Documentación interactiva generada con Swagger/OpenAPI.
- Pruebas de endpoints con Pytest y `TestClient`.
- Validación de respuestas HTTP como 200, 201, 401, 403 y 404.
- Control de versiones con Git y ramas por funcionalidad.
- README con instrucciones de instalación, ejecución y pruebas.
- Colección de solicitudes para validar los flujos principales.

## Aprendizajes principales

Este proyecto fortaleció mi comprensión de FastAPI, SQLite, seguridad basada en roles, pruebas de API y automatización de infraestructura. También me permitió practicar resolución de conflictos en Git, documentación técnica y evolución incremental de un producto a partir de nuevos requisitos.
