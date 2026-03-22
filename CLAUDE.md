# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Myanmar Real Estate Platform (缅甸房产平台) - a complete real estate transaction solution including:
- **C端 (Buyer App)**: Flutter app for property buyers
- **B端 (Agent App)**: Flutter app for real estate agents
- **Web Admin**: React-based management dashboard
- **WeChat Mini Program**: Native WeChat mini program
- **Backend**: Go-based microservices API

## Technology Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter 3.19 + Dart 3.0 + Riverpod |
| Backend | Go 1.21 + Gin + GORM |
| Database | PostgreSQL 15 + Redis 7 + Elasticsearch 8 |
| Web Admin | React 18 + TypeScript + UmiJS 4 + Ant Design 5 |
| Mini Program | WeChat Native + TypeScript |
| DevOps | Docker + Docker Compose |

## Common Commands

### Backend (Go)

```bash
cd myanmar-real-estate/backend

# Run the server (requires PostgreSQL, Redis, Elasticsearch)
go run cmd/server/main.go

# Or use Docker Compose to start all dependencies + API
docker-compose up -d

# The API will be available at http://localhost:8080
# Health check: GET http://localhost:8080/health
```

### Flutter Apps

```bash
cd myanmar-real-estate/flutter

# Install dependencies
flutter pub get

# Run Buyer App (C端)
flutter run -t lib/main_buyer.dart

# Run Agent App (B端)
flutter run -t lib/main_agent.dart

# Build release APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

### Web Admin

```bash
cd myanmar-real-estate/frontend/web-admin

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Type check
npm run type-check
```

### WeChat Mini Program

```bash
cd myanmar-real-estate/frontend/mini-program

# Install dependencies
npm install

# Type check
npm run type-check
```

Note: The mini program must be opened with WeChat Developer Tools.

## Architecture Overview

### Backend Architecture

The backend follows a layered architecture with domain-driven service organization:

```
cmd/server/main.go              # Entry point - initializes all modules
├── 03-user-service/            # User authentication & profiles
├── 04-house-service/           # Property listings & search
├── 05-acn-service/             # ACN commission distribution (5-role model)
├── 06-appointment-service/     # Viewing appointments & scheduling
├── 07-common/                  # Shared utilities (config, logger, DB, errors)
├── 08-im-service/              # Instant messaging
├── 09-verification-service/    # Property verification tasks
├── 10-utils/                   # Helper utilities
└── 11-upload-service/          # File upload handling
```

Each service follows this pattern:
- `model.go` - Data structures and GORM models
- `repository.go` - Database access layer
- `service.go` - Business logic
- `controller.go` - HTTP handlers

The main.go uses dependency injection to wire components:
```go
userRepo := userRepository.NewUserRepository(db)
jwtService := userService.NewJWTService(config)
userSvc := userService.NewUserService(userRepo, config, smsService, jwtService)
userCtrl := userController.NewUserController(userSvc)
userCtrl.RegisterRoutes(v1)
```

### Flutter Architecture

```
lib/
├── main_buyer.dart             # C端 entry point
├── main_agent.dart             # B端 entry point
├── buyer/                      # C端 features
│   ├── presentation/           # UI screens
│   └── providers/              # Riverpod state management
├── agent/                      # B端 features
│   ├── presentation/
│   └── providers/
├── core/                       # Shared infrastructure
│   ├── api/                    # Dio HTTP client
│   ├── constants/              # App constants
│   ├── models/                 # Data models
│   ├── router/                 # GoRouter configuration
│   ├── storage/                # Local storage (Hive, SharedPreferences)
│   ├── theme/                  # App themes
│   └── utils/                  # Utilities
└── shared/                     # Shared widgets
```

### Web Admin Architecture (UmiJS)

```
src/
├── pages/                      # File-based routing
│   ├── Dashboard/              # Dashboard page
│   ├── Agents/                 # Agent management
│   ├── Houses/                 # Property management
│   ├── Users/                  # User management
│   ├── Finance/                # Financial management
│   ├── Operations/             # Operations center
│   └── Settings/               # System settings
├── components/                 # Shared components
├── services/                   # API services
├── stores/                     # Zustand state stores
├── types/                      # TypeScript types
└── utils/                      # Utilities
```

## Key Design Patterns

### ACN Commission Model (核心难点)

The ACN (Agent Cooperation Network) service implements a 5-role commission distribution:
- **录入人 (Entry Agent)**: 35% of property side
- **维护人 (Maintainer)**: Share of property side
- **转介绍 (Referrer)**: Share of property side
- **带看人 (Viewer)**: 65% of client side
- **成交人 (Closer)**: Share of client side
- **Platform**: 10% fee

Key files: `05-acn-service/service.go`, `05-acn-service/model.go`

### Error Handling

Backend uses standardized error codes (0-7999) organized by module:
- 0-99: General errors
- 100-199: User module
- 200-299: Agent module
- 300-399: House module
- etc.

See `07-common/errors.go` for definitions.

### Database Schema

- 35 tables defined in `backend/01-database-schema.sql`
- Soft delete pattern with `deleted_at` columns
- JSONB fields for flexible metadata
- Geographic indexing for map search

## Testing

There are no automated test suites in the codebase yet. The project uses:
- QA test cases in `qa/test-cases/` (195 test cases)
- Mock server: `backend/mock_server.py` or `backend/full_mock_server.py`

## Docker Services

When running `docker-compose up` in `backend/`:
- PostgreSQL: localhost:5432 (user: myanmar_property, password: myanmar_property_2024)
- Redis: localhost:6379
- Elasticsearch: localhost:9200
- API: localhost:8080

## Important Notes

1. **Always work in the `myanmar-real-estate/` subdirectory** - the actual project is nested there
2. **The Makefile in `devops/Makefile` is outdated** - it references old paths like `frontend-web` and `mobile` that don't match the current structure
3. **IM Service is stubbed** - The IM service has interfaces but requires integration with Easemob (环信) or RongCloud (融云)
4. **Payment integration is pending** - Myanmar local payment channels need to be integrated
5. **Two Flutter entry points** - Always specify `-t lib/main_buyer.dart` or `-t lib/main_agent.dart`
