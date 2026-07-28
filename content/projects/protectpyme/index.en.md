---
title: "ProtectPYME"
description: "A cybersecurity training platform for SMEs using a 2D game, gamification, and adaptive artificial intelligence."
og_image: "images/og/protectpyme.png"
og_image_alt: "ProtectPYME: AI-powered cybersecurity training platform"
translationKey: "protectpyme"
weight: 10
featured: true
status: "In development"
category: "Cybersecurity + AI"
year: "2026"
period: "2026 – present"
role: "Backend developer and security specialist"
focus: "Secure backend, analytics, and adaptive AI"
project_type: "Engineering capstone project"
cover: "images/projects/protectpyme-cover.svg"
cover_alt: "ProtectPYME illustration featuring a digital shield, a video game, and artificial intelligence components"
repository_note: "Private working repository; architecture and technical decisions can be discussed during an interview."
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
  - "REST backend design and development"
  - "Security architecture and authentication"
  - "Data modeling and persistence"
  - "Decision and risk analytics"
  - "Recommendation integration with Unity"
  - "Technical documentation and testing"
key_outputs:
  - "OpenAPI-documented API"
  - "JWT authentication and authorization"
  - "Evaluation and recommendation engine"
  - "Random Forest risk-level model"
  - "Containerized environment"
card_points:
  - "Secure backend with FastAPI and PostgreSQL"
  - "Adaptive AI based on user performance"
  - "API–Unity integration and containerized deployment"
---

## Overview

ProtectPYME is an educational platform designed to support cybersecurity awareness training for employees at small and medium-sized businesses. The experience combines a 2D game built with Unity, decision-making scenarios, gamification, analytics, and artificial intelligence to adapt recommendations to each user’s performance.

My contribution focuses on the backend, security architecture, result processing, and technical integration between the web services and the game.

## Problem addressed

The project aims to transform cybersecurity concepts that are often presented theoretically into understandable interactive situations. The scenarios cover categories such as phishing, passwords, malware, and Wi-Fi networks, allowing the platform to record decisions and provide immediate feedback.

## My contribution

- Developed REST endpoints with FastAPI for users, scenarios, decisions, analytics, risk classification, badges, and leaderboards.
- Implemented JWT authentication and controls to protect application resources.
- Designed data models and persistence operations with PostgreSQL and SQLAlchemy.
- Developed rules to evaluate answers, calculate points, and generate feedback based on difficulty and category.
- Integrated analytics to identify the category with the highest number of errors for each user.
- Developed and integrated a Random Forest model that classifies educational risk as low, medium, or high.
- Built a hybrid recommendation engine connecting model results with specific training content and scenarios.
- Collaborated on the backend integration with Unity to present the risk level, recommendation message, and practice action.
- Prepared the environment with Docker, Docker Compose, and Nginx to simplify service execution and deployment.

## Architecture and main flow

```text
Unity user
    │
    ▼
Nginx / FastAPI service
    │
    ├── JWT authentication
    ├── Scenarios and decisions
    ├── Performance analytics
    │         │
    │         ▼
    │   Random Forest model
    │         │
    │         ▼
    │   Recommendation engine
    │
    ▼
PostgreSQL
```

The game sends decisions to the backend. The API validates the session, evaluates the response, and stores the result. The analytics module then calculates indicators such as accuracy, points, correct decisions, and risk index. The model classifies the user’s level, and the recommendation engine selects the scenario that should be practiced next.

## Applied artificial intelligence

The model uses variables derived from user behavior, including:

- Total points.
- Correct decisions.
- Total decisions.
- Accuracy.
- Awareness score.
- Risk index.

The output is not presented as a clinical diagnosis or an absolute judgment of the person. It works as an educational reference used to adapt content and guide practice within the platform.

## Security and quality

- Passwords protected through hashing mechanisms.
- Sessions controlled with JWT tokens.
- Data validation through FastAPI/Pydantic models.
- Separation between business logic, models, routes, and services.
- Centralized persistence in PostgreSQL.
- Automatic OpenAPI/Swagger documentation.
- Controlled testing of decision, analytics, and recommendation flows.
- Git and GitHub for version control and collaboration.

## Key lessons

This project has allowed me to connect backend development, databases, security, artificial intelligence, containers, and integration with a game engine. It has also strengthened my ability to document decisions, resolve integration issues, and communicate requirements across networking and interactive-environment teams.
