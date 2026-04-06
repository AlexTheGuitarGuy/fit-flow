# FitFlow — Claude Code Context

## Project Overview

FitFlow is a real-time workout tracking platform built as a portfolio/learning project.
The primary goal is to learn and demonstrate the tech stack — keep domain logic simple.

## Tech Stack

### Core

- **NestJS** — service framework with decorator-based architecture
- **Nx** — monorepo management with shared libraries
- **Apache Kafka (KRaft mode)** — event streaming, no Zookeeper

### Data

- **PostgreSQL** — primary relational database per service
- **Prisma** — ORM (preferred over TypeORM)
- **Redis** — caching, rate limiting, session storage

### Schema & Contracts

- **Apache Avro + Confluent Schema Registry** — enforce Kafka message schemas from day one
- **class-validator + class-transformer** — DTO validation within NestJS

### Infrastructure

- **Docker + Docker Compose** — local dev (Kafka, Schema Registry, PostgreSQL, Redis, all services)
- **Kubernetes + Helm** — production target
- **Kafka in KRaft mode** — no Zookeeper, simpler infrastructure

### Observability

- **OpenTelemetry** — distributed tracing across services
- **Prometheus + Grafana** — metrics and dashboards
- **Loki** — log aggregation

### Testing

- **Jest** — unit and integration tests (built into Nx)
- **Testcontainers** — real Kafka broker in integration tests, no mocks

### CI/CD

- **GitHub Actions** — use `nx affected` commands to only build/test changed services
- **Nx Cloud** — optional distributed cache for CI runs

---

## Monorepo Structure

```
fitflow/
├── apps/
│   ├── api-gateway/        # HTTP entry point, routes to services
│   ├── user-service/       # Registration, profiles, JWT auth
│   ├── workout-service/    # Create and log workouts/exercises
│   ├── stats-service/      # Consumes events, computes PRs, streaks, totals
│   └── notification-service/ # Consumes events, sends in-app alerts
├── libs/
│   ├── auth/               # Shared JWT guard, decorators — used by all services
│   ├── kafka/              # Shared Kafka client config, producer/consumer helpers
│   ├── dto/                # Shared DTOs and Zod/class-validator schemas
│   └── events/             # Kafka event type definitions (Avro schemas live here)
├── docker-compose.yml
├── CLAUDE.md
└── README.md
```

---

## Services Overview

| Service              | Transport             | Responsibility                                     |
| -------------------- | --------------------- | -------------------------------------------------- |
| API Gateway          | HTTP (REST)           | Single entry point, routes to downstream services  |
| User Service         | HTTP + Kafka consumer | Auth (JWT), user profiles, emits `user.registered` |
| Workout Service      | HTTP + Kafka producer | CRUD for workouts/exercises, emits workout events  |
| Stats Service        | Kafka consumer only   | Computes personal records, streaks, totals         |
| Notification Service | Kafka consumer only   | Sends in-app alerts based on events                |

---

## Kafka Events

All events must have an Avro schema registered in the Schema Registry before use.

| Event                      | Producer        | Consumers                           |
| -------------------------- | --------------- | ----------------------------------- |
| `user.registered`          | User Service    | Notification Service                |
| `workout.started`          | Workout Service | Stats Service                       |
| `workout.completed`        | Workout Service | Stats Service, Notification Service |
| `personal-record.achieved` | Stats Service   | Notification Service                |

### Event Naming Convention

- Format: `{domain}.{past-tense-verb}`
- Examples: `workout.completed`, `user.registered`, `personal-record.achieved`

---

## Architecture Decisions

- **KRaft mode only** — no Zookeeper; simpler local dev and production setup
- **Schema Registry from day one** — do not skip this; retrofitting Avro later is painful
- **Event-driven between services** — services react to things that _happened_, not direct commands
- **HTTP only at the Gateway** — internal service-to-service communication is Kafka only (no REST between services)
- **Shared libs over duplication** — auth guards, event types, DTOs always go in `libs/`, never duplicated across services
- **One database per service** — services do not share databases; query via events or gateway

---

## Domain Model (Keep It Simple)

```
User        { id, name, email, passwordHash, createdAt }
Workout     { id, userId, name, startedAt, completedAt }
Exercise    { id, workoutId, name, sets, reps, weightKg }
PersonalRecord { id, userId, exerciseName, weightKg, achievedAt }
Notification { id, userId, message, read, createdAt }
```

---

## Local Dev Setup

Start everything with Docker Compose:

```bash
docker-compose up -d
```

This should spin up:

- Kafka (KRaft)
- Confluent Schema Registry
- PostgreSQL (one instance per service, separate DBs)
- Redis
- All NestJS services

Run a specific service locally (outside Docker):

```bash
nx serve user-service
```

Run all tests:

```bash
nx run-many --target=test --all
```

Run tests for affected services only (CI):

```bash
nx affected:test
```

---

## Key Reminders

- This is a **learning project** — favour clarity over cleverness
- Always register Avro schemas before producing events
- Keep domain logic thin; the interesting complexity is in the infrastructure
- When in doubt, check `libs/` before writing something new in a service
