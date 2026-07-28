---
title: "ProtectPYME"
description: "Plataforma de capacitación en ciberseguridad para PYMES mediante un videojuego 2D, gamificación e inteligencia artificial adaptativa."
translationKey: "protectpyme"
weight: 10
featured: true
status: "En desarrollo"
category: "Ciberseguridad + IA"
year: "2026"
period: "2026 – actualidad"
role: "Desarrolladora backend y especialista en seguridad"
focus: "Backend seguro, analítica e IA adaptativa"
project_type: "Proyecto de Ingeniería"
cover: "images/projects/protectpyme-cover.svg"
cover_alt: "Ilustración de ProtectPYME con un escudo digital, un videojuego y componentes de inteligencia artificial"
repository_note: "Repositorio de trabajo privado; la arquitectura y las decisiones técnicas pueden explicarse durante una entrevista."
stack:
  - "Python"
  - "FastAPI"
  - "PostgreSQL"
  - "SQLAlchemy"
  - "JWT"
  - "Random Forest"
  - "Docker"
  - "Docker Compose"
  - "Nginx"
  - "Unity"
  - "Git & GitHub"
responsibilities:
  - "Diseño y desarrollo del backend REST"
  - "Arquitectura de seguridad y autenticación"
  - "Modelado y persistencia de datos"
  - "Analítica de decisiones y riesgo"
  - "Integración de recomendaciones con Unity"
  - "Documentación y pruebas técnicas"
key_outputs:
  - "API documentada con OpenAPI"
  - "Autenticación y autorización con JWT"
  - "Motor de evaluación y recomendaciones"
  - "Modelo Random Forest para nivel de riesgo"
  - "Entorno contenerizado"
card_points:
  - "Backend seguro con FastAPI y PostgreSQL"
  - "IA adaptativa basada en desempeño"
  - "Integración API–Unity y despliegue con contenedores"
---

## Resumen

ProtectPYME es una plataforma educativa diseñada para apoyar la capacitación en ciberseguridad de personal de pequeñas y medianas empresas. La experiencia combina un videojuego 2D desarrollado en Unity, escenarios de toma de decisiones, gamificación, analítica e inteligencia artificial para adaptar las recomendaciones al desempeño de cada usuario.

Mi participación se concentra en el backend, la arquitectura de seguridad, el procesamiento de resultados y la integración técnica entre los servicios web y el videojuego.

## Problema abordado

El proyecto busca convertir conceptos de seguridad que suelen presentarse de forma teórica en situaciones interactivas y comprensibles. Los escenarios trabajan categorías como phishing, contraseñas, malware y redes Wi-Fi, permitiendo registrar decisiones y ofrecer retroalimentación inmediata.

## Mi contribución

- Desarrollo de endpoints REST con FastAPI para usuarios, escenarios, decisiones, analítica, clasificación de riesgo, insignias y tabla de posiciones.
- Implementación de autenticación con JWT y controles para proteger los recursos de la aplicación.
- Diseño de modelos y operaciones de persistencia con PostgreSQL y SQLAlchemy.
- Desarrollo de reglas para evaluar respuestas, calcular puntos y generar retroalimentación según la dificultad y la categoría.
- Integración de analítica para identificar la categoría con mayor número de errores por usuario.
- Desarrollo e integración de un modelo Random Forest que clasifica el riesgo educativo en niveles bajo, medio o alto.
- Construcción de un motor híbrido de recomendaciones que relaciona el resultado del modelo con entrenamientos y escenarios específicos.
- Colaboración en la integración del backend con Unity para presentar el nivel de riesgo, el mensaje recomendado y el botón de práctica.
- Preparación del entorno con Docker, Docker Compose y Nginx para facilitar la ejecución y el despliegue de los servicios.

## Arquitectura y flujo principal

```text
Usuario en Unity
      │
      ▼
Nginx / API FastAPI
      │
      ├── Autenticación JWT
      ├── Escenarios y decisiones
      ├── Analítica de desempeño
      │         │
      │         ▼
      │   Modelo Random Forest
      │         │
      │         ▼
      │   Motor de recomendaciones
      │
      ▼
PostgreSQL
```

El videojuego envía decisiones al backend. La API valida la sesión, evalúa la respuesta y almacena el resultado. Después, el módulo de analítica calcula indicadores como precisión, puntos, decisiones correctas e índice de riesgo. El modelo clasifica el nivel del usuario y el motor de recomendaciones selecciona el escenario que conviene practicar.

## Inteligencia artificial aplicada

El modelo utiliza variables derivadas del comportamiento del usuario, entre ellas:

- Puntos totales.
- Decisiones correctas.
- Total de decisiones.
- Precisión.
- Indicador de concientización.
- Índice de riesgo.

La salida no se presenta como un diagnóstico clínico ni como una evaluación absoluta de la persona. Funciona como una referencia educativa para adaptar el contenido y orientar la práctica dentro de la plataforma.

## Seguridad y calidad

- Contraseñas protegidas mediante mecanismos de hash.
- Sesiones controladas mediante tokens JWT.
- Validación de datos a través de modelos de FastAPI/Pydantic.
- Separación entre lógica de negocio, modelos, rutas y servicios.
- Persistencia centralizada en PostgreSQL.
- Documentación automática con OpenAPI/Swagger.
- Pruebas controladas del flujo de decisiones, analítica y recomendaciones.
- Uso de Git y GitHub para control de versiones y colaboración.

## Aprendizajes principales

Este proyecto me ha permitido conectar desarrollo backend, bases de datos, seguridad, inteligencia artificial, contenedores e integración con un motor gráfico. También ha fortalecido mi capacidad para documentar decisiones, corregir errores de integración y comunicar requisitos entre perfiles de redes y desarrollo de entornos interactivos.
