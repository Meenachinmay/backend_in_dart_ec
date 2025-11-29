# Supermarket Backend

A production-grade Dart backend service for an Online Supermarket, built with **Clean Architecture**, **Shelf**, **PostgreSQL**, and **Docker**.

## Features

- **User Management**: Create and view user profiles.
- **Inventory System**: 
  - List items with dynamic pricing based on expiry.
  - **Discounts**: 
    - 1 Day left: 50% OFF
    - 2 Days left: 30% OFF
    - 3 Days left: 10% OFF
- **Subscriptions**: Users can subscribe to specific items to get alerted when they reach a specific expiry threshold.
- **Notifications**: Logic to identify subscriptions that need alerts (e.g., "Milk expires in 1 day").

## Tech Stack

- **Language**: Dart
- **Framework**: Shelf (Server), Shelf Router
- **Database**: PostgreSQL 15
- **Architecture**: Clean Architecture (Handlers -> Services -> Repositories -> Data Source)
- **Dependency Injection**: `get_it`
- **Containerization**: Docker & Docker Compose

## Getting Started

### Prerequisites

- Docker & Docker Compose installed.

### Running the App

1. **Start the services**:
   ```bash
   docker-compose up --build
   ```
   This starts the PostgreSQL database and the Dart server (exposed on port `8080`).

2. **Verify Health**:
   ```bash
   curl http://localhost:8080/health
   ```

## API Endpoints

### Users
- `POST /api/v1/users` - Create a user (`{ "email": "..." }`)
- `GET /api/v1/users/<id>` - Get user details

### Inventory
- `GET /api/v1/inventory/` - List all items with calculated discounts.

### Subscriptions
- `POST /api/v1/subscriptions/` - Subscribe to an item (`{ "user_id": "...", "inventory_id": "...", "alert_threshold": 1 }`)
- `GET /api/v1/subscriptions/user/<user_id>` - List user subscriptions.
- `POST /api/v1/subscriptions/trigger-check` - **(Demo)** Simulate a notification check and return who would be alerted.

## Project Structure

- `bin/` - Entry point.
- `lib/api/` - Handlers, Routers, Middleware.
- `lib/services/` - Business Logic (Discounts, Notification rules).
- `lib/data/` - Repositories & DB Connection.
- `lib/domain/` - Models.
- `lib/config/` - Dependency Injection & Environment.
- `db/` - SQL migrations/seeds.

## Future Work
- Integrate Firebase Admin SDK in `auth_middleware.dart`.
- Integrate Redis for caching inventory.
- Connect `trigger-check` to a real Email/Push service.
