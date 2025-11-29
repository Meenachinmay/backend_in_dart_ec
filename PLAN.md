# Project Plan: 10x-Supermarket Backend (Dart)

## 1. Architecture & Tech Stack
We will build a **pure server-side service** using **Dart** with a **Clean Architecture** approach. This ensures separation of concerns, testability, and flexibility for future expansions (gRPC, Redis, etc.).

### Tech Stack
- **Language:** Dart (latest stable version)
- **Core Framework:** `shelf` (Standard, composable web server interface for Dart) + `shelf_router`.
- **Database:** PostgreSQL (via Docker).
- **Database Access:** `postgres` package (v3, enabling connection pooling and robust query execution).
- **Dependency Injection:** `get_it` (Service Locator pattern) to manage singletons (DB connection, Services, Repositories).
- **Environment:** `dotenv` for configuration.
- **Containerization:** Docker & Docker Compose.

### Layered Architecture
1.  **Presentation Layer (Handlers/Routers):** Handles HTTP requests, validates input, calls Services.
2.  **Domain/Service Layer:** Contains business logic (e.g., calculating discounts, handling subscriptions).
3.  **Data/Repository Layer:** interacts strictly with the Database.
4.  **Infrastructure:** Database connections, Redis (future), 3rd party APIs (Firebase Admin - future).

---

## 2. Database Schema (PostgreSQL)

### `users`
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `id` | UUID/SERIAL | PK |
| `email` | VARCHAR | UNIQUE, NOT NULL |
| `created_at` | TIMESTAMP | DEFAULT NOW() |
| `updated_at` | TIMESTAMP | DEFAULT NOW() |

### `inventory`
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `id` | UUID/SERIAL | PK |
| `name` | VARCHAR | NOT NULL |
| `price` | DECIMAL | NOT NULL (Original Price) |
| `discounted_price` | DECIMAL | (Calculated/Stored) |
| `expiry_in` | INTEGER | NOT NULL (Days remaining: 1, 2, 3...) |
| `created_at` | TIMESTAMP | DEFAULT NOW() |
| `updated_at` | TIMESTAMP | DEFAULT NOW() |

### `subscriptions`
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `id` | UUID/SERIAL | PK |
| `user_id` | UUID/SERIAL | FK -> users(id) |
| `inventory_id` | UUID/SERIAL | FK -> inventory(id) |
| `alert_threshold` | INTEGER | NOT NULL (User preference: 1, 2, or 3 days) |
| `created_at` | TIMESTAMP | DEFAULT NOW() |

---

## 3. Core Features & Logic

### A. User Management
- **Create Profile:** `POST /api/v1/users`
- **Get Profile:** `GET /api/v1/users/{id}`

### B. Inventory Management
- **List Inventory:** `GET /api/v1/inventory`
    - **Logic:** When listing, the service will check `expiry_in` and dynamically calculate the `discounted_price` if not already consistent.
    - **Discount Rules:**
        - `expiry_in` == 1 day  -> **50% OFF**
        - `expiry_in` == 2 days -> **30% OFF**
        - `expiry_in` == 3 days -> **10% OFF**
        - Else -> 0% OFF (Original Price)

### C. Subscriptions
- **Subscribe:** `POST /api/v1/subscriptions`
    - **Input:** `{ "user_id": "...", "inventory_id": "...", "alert_threshold": 2 }`
    - **Logic:** Validates user and inventory exist. Saves the preference.
- **Logic Note:** The prompt mentions "sending notifications". Since we are implementing the *backend* structure first:
    - We will implement a `NotificationService` placeholder.
    - We can expose an endpoint `GET /api/v1/notifications/check` (or a background cron function) that queries:
      `SELECT * FROM subscriptions s JOIN inventory i ON s.inventory_id = i.id WHERE i.expiry_in = s.alert_threshold`
      and triggers the notification.

### D. Authentication
- **Middleware:** A `firebaseAuthMiddleware` will be stubbed out to extract Bearer tokens. It will be ready to integrate `firebase_admin` later.

---

## 4. Development Roadmap

1.  **Setup Phase:**
    - Initialize Dart project structure.
    - Create `docker-compose.yaml` with PostgreSQL.
    - Create `Dockerfile` for the Dart app.

2.  **Database & Models:**
    - Write SQL initialization scripts.
    - Create Dart Data classes (Models).

3.  **Implementation (Iterative):**
    - **Repo Layer:** Implement `UserRepository`, `InventoryRepository`, `SubscriptionRepository`.
    - **Service Layer:** Implement `InventoryService` (Discount logic), `SubscriptionService`.
    - **API Layer:** Setup `Shelf` router and endpoints.

4.  **Verification:**
    - Run the app in Docker.
    - Test endpoints using `curl` or a script.

---

## 5. Future Considerations (Production Grade)
- **gRPC:** The Clean Architecture allows adding a gRPC "Delivery Layer" alongside the HTTP layer, reusing the same Services and Repositories.
- **Redis:** Can be added to the Repository layer for caching inventory lists.
- **WebSockets:** `shelf_web_socket` can be added for real-time price updates.
