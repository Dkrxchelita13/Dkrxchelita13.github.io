---
title: "NetAdmin API"
description: "A REST API for inventory, scanning, monitoring, and remote administration of network devices."
og_image: "images/og/netadmin-api.png"
og_image_alt: "NetAdmin API: network inventory, automation, and administration"
translationKey: "netadmin-api"
weight: 20
featured: true
status: "Functional · continuously improving"
category: "Backend + Networking"
year: "2026"
period: "2026"
role: "Backend and network automation developer"
focus: "Inventory, monitoring, and secure administration"
project_type: "Academic project"
cover: "images/projects/netadmin-cover.svg"
cover_alt: "NetAdmin API illustration featuring network devices, a terminal, and connected nodes"
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
  - "CRUD and scanning endpoint design"
  - "Persistence and change history"
  - "Authentication and role-based access"
  - "Automation with Netmiko and Paramiko"
  - "Dashboard, reports, and alerts"
  - "Testing and documentation"
key_outputs:
  - "Documented REST API"
  - "Persistent SQLite inventory"
  - "Controlled remote execution"
  - "Dashboard and scheduled scanning"
  - "PDF reports and alerts"
card_points:
  - "Network-device inventory and scanning"
  - "Remote administration with Netmiko and Paramiko"
  - "Authentication, history, reports, and alerts"
---

## Overview

NetAdmin API is a solution developed to centralize inventory, discovery, monitoring, and administration tasks for network devices. The project began as a REST API and evolved to incorporate persistence, authentication, change history, a dashboard, reports, and alerts.

Its technical goal is to reduce repetitive manual work and provide an organized foundation for querying devices, recording changes, and executing remote actions in a controlled manner.

## Main capabilities

- Create, read, update, and delete devices through CRUD endpoints.
- Search for devices by IP address.
- Scan CIDR networks to discover active hosts.
- Export inventory data in JSON, YAML, and XML formats.
- Store data locally using SQLite.
- Record a history of additions, updates, and deletions.
- Compare current and previous configurations.
- Authenticate users through tokens and separate administrator and read-only permissions.
- Execute commands on Cisco switches with Netmiko.
- Administer Linux servers through Paramiko/SSH.
- Display inventory metrics through a web dashboard.
- Run scheduled automatic scans.
- Generate PDF reports.
- Send alerts through Telegram and email.
- Validate behavior through automated Pytest tests.

## Architecture and modules

```text
Client / Swagger / Dashboard
            │
            ▼
        FastAPI
            │
   ┌────────┼───────────┐
   ▼        ▼           ▼
Inventory   Security    Automation
SQLite      Tokens      Netmiko / Paramiko
   │                    │
   ▼                    ▼
History               Cisco switches
Reports               Linux servers
Alerts
```

The application separates authentication, database access, inventory, scanning, export, and remote-administration responsibilities into modules. This approach makes each component easier to test and allows new capabilities to be added without concentrating all logic in one file.

## Security and access control

The system separates two primary profiles:

- **Administrator:** can create, modify, and delete devices, run scans, and use remote-administration capabilities.
- **Read-only user:** can authenticate and review permitted information without modifying inventory data.

Protected routes validate both the token and user role before executing an operation. Passwords are not stored in plain text, and authentication failures use specific HTTP responses.

## Network automation

Netmiko is used to work with compatible network devices through SSH, while Paramiko establishes sessions with Linux servers. These operations are exposed through protected endpoints and are intended for authorized environments.

Network scanning uses CIDR ranges. During testing, smaller ranges made it possible to validate discovery without running unnecessarily broad searches.

## Persistence, tracking, and alerts

SQLite stores both inventory data and its change history. Each change can record the action, IP address, previous data, new data, and date. This supports auditing and configuration comparisons.

PDF reports consolidate relevant results, while alerts communicate events through Telegram or email.

## Quality and documentation

- Interactive Swagger/OpenAPI documentation.
- Endpoint tests with Pytest and `TestClient`.
- Validation of HTTP responses such as 200, 201, 401, 403, and 404.
- Git version control with feature branches.
- README documentation for installation, execution, and testing.
- Request collection for validating the main workflows.

## Key lessons

This project strengthened my understanding of FastAPI, SQLite, role-based security, API testing, and infrastructure automation. It also allowed me to practice Git conflict resolution, technical documentation, and incremental product evolution based on new requirements.
