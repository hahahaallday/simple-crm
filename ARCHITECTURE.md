# System Architecture Document
## Cross-Border Ecommerce CRM

**Version**: 1.0
**Date**: 2026-01-19
**Status**: Final

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Architecture Goals and Principles](#2-architecture-goals-and-principles)
3. [High-Level Architecture](#3-high-level-architecture)
4. [Component Architecture](#4-component-architecture)
5. [Data Architecture](#5-data-architecture)
6. [API Architecture](#6-api-architecture)
7. [Integration Architecture](#7-integration-architecture)
8. [Security Architecture](#8-security-architecture)
9. [Deployment Architecture](#9-deployment-architecture)
10. [Scalability Architecture](#10-scalability-architecture)
11. [Technology Stack Rationale](#11-technology-stack-rationale)
12. [Design Patterns](#12-design-patterns)
13. [Development Architecture](#13-development-architecture)
14. [Monitoring and Observability](#14-monitoring-and-observability)
15. [Disaster Recovery and Backup](#15-disaster-recovery-and-backup)
16. [Architecture Decision Records](#16-architecture-decision-records)

---

## 1. Architecture Overview

### 1.1 Purpose

This document describes the technical architecture of the Cross-Border Ecommerce CRM system. It provides a comprehensive view of the system's structure, components, interactions, and design decisions to guide development and future enhancements.

### 1.2 Scope

The CRM system is designed to manage customer relationships for cross-border ecommerce businesses, supporting:
- Multi-currency transactions
- Multi-language interfaces
- International customer data management
- Order tracking across borders
- Integration with ecommerce platforms (Shopify, WooCommerce)
- Email communication capabilities
- Analytics and reporting

### 1.3 System Context

```
┌────────────────────────────────────────────────────────────────┐
│                      External Systems                          │
│  - Shopify Stores                                              │
│  - WooCommerce Sites                                           │
│  - Email Services (SendGrid/AWS SES)                           │
│  - Currency Exchange APIs                                      │
│  - Cloud Storage (AWS S3)                                      │
└────────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌────────────────────────────────────────────────────────────────┐
│                    CRM System                                  │
│  - Customer Management                                         │
│  - Order Management                                            │
│  - Activity Tracking                                           │
│  - Analytics                                                   │
│  - Communication Hub                                           │
└────────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌────────────────────────────────────────────────────────────────┐
│                    End Users                                   │
│  - Customer Support Agents                                     │
│  - Sales Managers                                              │
│  - Marketing Teams                                             │
│  - System Administrators                                       │
└────────────────────────────────────────────────────────────────┘
```

---

## 2. Architecture Goals and Principles

### 2.1 Goals

1. **Scalability**: Support 100,000+ customers and 1,000+ concurrent users
2. **Performance**: API response times < 200ms (p95)
3. **Reliability**: 99.9% uptime
4. **Security**: Enterprise-grade security with GDPR compliance
5. **Maintainability**: Clean code architecture with >80% test coverage
6. **Extensibility**: Easy to add new integrations and features
7. **Cross-Border Ready**: Built-in multi-currency, multi-language support

### 2.2 Architectural Principles

1. **Separation of Concerns**: Clear boundaries between frontend, backend, and data layers
2. **API-First Design**: RESTful API as the contract between frontend and backend
3. **Stateless Services**: Services don't maintain session state (stored in Redis/DB)
4. **Asynchronous Processing**: Use Celery for long-running tasks (sync, email, webhooks)
5. **Fail-Safe Design**: Graceful degradation when external services are unavailable
6. **Security by Default**: Authentication, authorization, and encryption at all layers
7. **Test-Driven Development**: Comprehensive test coverage for reliability
8. **Convention over Configuration**: Follow Django and React best practices
9. **Data Integrity**: Use database constraints and validations
10. **Observability**: Comprehensive logging, monitoring, and alerting

---

## 3. High-Level Architecture

### 3.1 Layered Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  React Frontend (TypeScript + Vite)                          │   │
│  │  - Pages, Components, State Management (Zustand)             │   │
│  │  - Routing (React Router), Forms (React Hook Form)          │   │
│  │  - UI Components (Tailwind + shadcn/ui)                     │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑ (HTTPS/REST)
┌─────────────────────────────────────────────────────────────────────┐
│                          API Layer                                  │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Django REST Framework                                        │   │
│  │  - Authentication (JWT)                                       │   │
│  │  - Authorization (RBAC)                                       │   │
│  │  - Rate Limiting                                              │   │
│  │  - Request Validation                                         │   │
│  │  - API Documentation (drf-spectacular)                        │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                     Business Logic Layer                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Django Apps (Services)                                       │   │
│  │  - Customers (CRUD, segmentation, import/export)             │   │
│  │  - Orders (tracking, multi-currency normalization)           │   │
│  │  - Activities (timeline, tasks, notes)                       │   │
│  │  - Communications (email templates, sending)                 │   │
│  │  - Integrations (Shopify, WooCommerce sync)                  │   │
│  │  - Analytics (metrics, reports, caching)                     │   │
│  │  - Users (team management, permissions)                      │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                        Data Layer                                   │
│  ┌──────────────────┬────────────────┬──────────────────────────┐   │
│  │  PostgreSQL      │  Redis         │  File Storage (S3)       │   │
│  │  - Primary DB    │  - Cache       │  - Attachments           │   │
│  │  - Relationships │  - Celery Queue│  - Exports               │   │
│  │  - ACID          │  - Sessions    │  - User Avatars          │   │
│  └──────────────────┴────────────────┴──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                    Background Processing                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Celery Workers                                               │   │
│  │  - Shopify sync (customers, orders)                          │   │
│  │  - Email sending (queued)                                    │   │
│  │  - Webhook processing                                        │   │
│  │  - Data exports (CSV, PDF)                                   │   │
│  │  - Analytics cache refresh                                   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Communication Patterns

- **Frontend ↔ Backend**: REST API over HTTPS with JWT tokens
- **Backend ↔ Database**: Django ORM with connection pooling
- **Backend ↔ Cache**: Redis for session storage, query caching, and rate limiting
- **Backend ↔ Workers**: Celery tasks via Redis message broker
- **External Systems → Backend**: Webhooks (POST requests with signature verification)
- **Backend → External Systems**: REST API calls with retry logic

---

## 4. Component Architecture

### 4.1 Frontend Architecture

#### 4.1.1 Directory Structure

```
frontend/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── ui/             # Base UI components (Button, Input, etc.)
│   │   ├── common/         # Common components (Header, Sidebar, etc.)
│   │   └── shared/         # Shared business components
│   ├── features/           # Feature-based organization
│   │   ├── customers/
│   │   │   ├── components/ # Customer-specific components
│   │   │   ├── hooks/      # Custom hooks
│   │   │   ├── api.ts      # API calls
│   │   │   └── types.ts    # TypeScript types
│   │   ├── orders/
│   │   ├── activities/
│   │   ├── analytics/
│   │   └── settings/
│   ├── layouts/            # Page layouts
│   │   ├── MainLayout.tsx
│   │   ├── AuthLayout.tsx
│   │   └── PublicLayout.tsx
│   ├── pages/              # Route pages
│   ├── store/              # Zustand state stores
│   │   ├── authStore.ts
│   │   ├── customersStore.ts
│   │   └── uiStore.ts
│   ├── services/           # API service layer
│   │   ├── api.ts          # Axios instance
│   │   ├── auth.ts
│   │   ├── customers.ts
│   │   └── orders.ts
│   ├── utils/              # Utility functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── helpers.ts
│   ├── types/              # Global TypeScript types
│   ├── hooks/              # Global custom hooks
│   ├── App.tsx
│   └── main.tsx
```

#### 4.1.2 State Management Strategy

**Zustand Stores:**
- `authStore`: User authentication state, tokens, current user
- `customersStore`: Customer list, filters, pagination, selected customer
- `ordersStore`: Order list, filters, pagination
- `uiStore`: UI state (modals, toasts, loading states)
- `settingsStore`: User preferences, theme, language

**Local Component State:**
- Form state (React Hook Form)
- UI interactions (dropdowns, tooltips)
- Temporary data

#### 4.1.3 Routing Strategy

```typescript
// Protected routes structure
<BrowserRouter>
  <Routes>
    <Route path="/login" element={<Login />} />
    <Route path="/reset-password" element={<ResetPassword />} />

    <Route element={<ProtectedRoute />}>
      <Route path="/" element={<MainLayout />}>
        <Route index element={<Dashboard />} />
        <Route path="customers" element={<Customers />} />
        <Route path="customers/:id" element={<CustomerDetail />} />
        <Route path="orders" element={<Orders />} />
        <Route path="orders/:id" element={<OrderDetail />} />
        <Route path="activities" element={<Activities />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="settings/*" element={<Settings />} />
      </Route>
    </Route>
  </Routes>
</BrowserRouter>
```

### 4.2 Backend Architecture

#### 4.2.1 Django Project Structure

```
backend/
├── config/                     # Project configuration
│   ├── settings/
│   │   ├── base.py            # Base settings
│   │   ├── development.py     # Dev overrides
│   │   ├── production.py      # Prod overrides
│   │   └── test.py            # Test overrides
│   ├── urls.py                # Root URL configuration
│   ├── wsgi.py                # WSGI application
│   └── celery.py              # Celery configuration
├── apps/                       # Django applications
│   ├── customers/
│   │   ├── models.py          # Customer, Tag, Segment models
│   │   ├── serializers.py     # DRF serializers
│   │   ├── views.py           # ViewSets
│   │   ├── filters.py         # django-filter classes
│   │   ├── permissions.py     # Custom permissions
│   │   ├── services.py        # Business logic
│   │   ├── tasks.py           # Celery tasks
│   │   ├── urls.py            # URL routing
│   │   ├── admin.py           # Django admin
│   │   └── tests/
│   ├── orders/
│   ├── activities/
│   ├── users/
│   ├── communications/
│   ├── integrations/
│   └── analytics/
├── common/                     # Shared utilities
│   ├── middleware.py
│   ├── exceptions.py
│   ├── validators.py
│   └── utils.py
├── manage.py
└── requirements/
```

#### 4.2.2 Service Layer Pattern

Each Django app follows this pattern:

```python
# models.py - Data models only
class Customer(models.Model):
    email = models.EmailField(unique=True)
    # ... fields

# serializers.py - Data transformation
class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

# services.py - Business logic
class CustomerService:
    @staticmethod
    def create_customer(data):
        # Business logic, validation
        # Call other services
        return customer

    @staticmethod
    def calculate_ltv(customer):
        # Complex calculations
        pass

# views.py - API endpoints
class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request):
        # Use service layer
        customer = CustomerService.create_customer(request.data)
        serializer = self.get_serializer(customer)
        return Response(serializer.data)
```

#### 4.2.3 Authentication Flow

```
1. User logs in with email/password
   ↓
2. Backend validates credentials
   ↓
3. Generate JWT tokens (access + refresh)
   - Access token: expires in 15 minutes
   - Refresh token: expires in 7 days
   ↓
4. Frontend stores tokens (localStorage or httpOnly cookie)
   ↓
5. Every request includes: Authorization: Bearer <access_token>
   ↓
6. If access token expires, use refresh token to get new access token
   ↓
7. If refresh token expires, redirect to login
```

#### 4.2.4 Permission System

**Role Hierarchy:**
```
Admin > Manager > Agent > Read-only
```

**Permission Classes:**
```python
class IsAdminUser(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'admin'

class IsManagerOrAbove(BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ['admin', 'manager']

class CanEditCustomer(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        return request.user.role in ['admin', 'manager']
```

---

## 5. Data Architecture

### 5.1 Database Design

#### 5.1.1 Entity Relationship Diagram

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   User       │         │  Customer    │         │    Order     │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ id (PK)      │         │ id (PK)      │◄────────│ id (PK)      │
│ email        │         │ email        │   1:N   │ customer_id  │
│ first_name   │         │ first_name   │         │ order_number │
│ last_name    │         │ last_name    │         │ total_amount │
│ role         │         │ country_code │         │ currency     │
│ status       │         │ timezone     │         │ status       │
└──────┬───────┘         │ language     │         └──────┬───────┘
       │                 │ currency     │                │
       │                 │ status       │                │
       │                 │ ltv          │                │
       │                 └──────┬───────┘                │
       │                        │                        │
       │                        │ 1:N                    │ 1:N
       │                        │                        │
       │                 ┌──────▼───────┐         ┌─────▼────────┐
       │                 │  Activity    │         │  OrderItem   │
       │                 ├──────────────┤         ├──────────────┤
       └─────────────────┤ id (PK)      │         │ id (PK)      │
                 1:N     │ customer_id  │         │ order_id     │
                         │ user_id      │         │ product_name │
                         │ type         │         │ quantity     │
                         │ subject      │         │ unit_price   │
                         │ description  │         └──────────────┘
                         └──────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│     Tag      │         │CustomerTag   │         │   Segment    │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ id (PK)      │◄────────│ customer_id  │         │ id (PK)      │
│ name         │   N:M   │ tag_id       │         │ name         │
│ color        │         └──────────────┘         │ conditions   │
└──────────────┘                                  │ created_by   │
                                                  └──────────────┘

┌──────────────┐         ┌──────────────┐
│ Integration  │         │EmailTemplate │
├──────────────┤         ├──────────────┤
│ id (PK)      │         │ id (PK)      │
│ platform     │         │ name         │
│ shop_name    │         │ language     │
│ credentials  │         │ subject      │
│ status       │         │ body         │
│ last_sync_at │         │ variables    │
└──────────────┘         └──────────────┘
```

#### 5.1.2 Core Tables Schema

**Users Table:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'manager', 'agent', 'readonly')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive')),
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    avatar_url TEXT,
    last_login TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
```

**Customers Table:**
```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(50),
    company_name VARCHAR(255),
    country_code CHAR(2) NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive', 'vip', 'blocked')),
    custom_fields JSONB,
    lifetime_value DECIMAL(15, 2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    average_order_value DECIMAL(15, 2) DEFAULT 0.00,
    first_order_date TIMESTAMP,
    last_order_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_country ON customers(country_code);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_created_at ON customers(created_at);
CREATE INDEX idx_customers_ltv ON customers(lifetime_value);
CREATE INDEX idx_customers_custom_fields ON customers USING GIN (custom_fields);
```

**Orders Table:**
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    total_amount DECIMAL(15, 2) NOT NULL,
    currency CHAR(3) NOT NULL,
    total_amount_usd DECIMAL(15, 2) NOT NULL,
    tax_amount DECIMAL(15, 2) DEFAULT 0.00,
    shipping_amount DECIMAL(15, 2) DEFAULT 0.00,
    shipping_country CHAR(2),
    shipping_address JSONB,
    tracking_number VARCHAR(255),
    carrier VARCHAR(100),
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    source VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_total_amount_usd ON orders(total_amount_usd);
```

#### 5.1.3 Database Optimization Strategies

1. **Indexing Strategy:**
   - Primary keys (automatic)
   - Foreign keys (for joins)
   - Frequently filtered columns (status, country_code, created_at)
   - Search columns (email, order_number)
   - JSONB columns with GIN indexes

2. **Query Optimization:**
   - Use `select_related()` for foreign keys
   - Use `prefetch_related()` for many-to-many
   - Avoid N+1 queries
   - Use `only()` and `defer()` for large models

3. **Connection Pooling:**
   - Configure Django DB connection pool (persistent connections)
   - Set appropriate timeouts

4. **Partitioning Strategy (Future):**
   - Partition orders by date range (monthly/quarterly)
   - Partition activities by date range

### 5.2 Caching Strategy

#### 5.2.1 Redis Cache Layers

```
┌─────────────────────────────────────────────────────┐
│            Cache Layer (Redis)                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Session Cache                                   │
│     - User sessions                                 │
│     - JWT blacklist                                 │
│     TTL: 7 days                                     │
│                                                     │
│  2. Query Cache                                     │
│     - Customer lists (filtered)                     │
│     - Order lists                                   │
│     TTL: 5 minutes                                  │
│                                                     │
│  3. Analytics Cache                                 │
│     - Dashboard metrics                             │
│     - Reports                                       │
│     TTL: 1 hour                                     │
│                                                     │
│  4. Rate Limiting                                   │
│     - API rate limits per user/IP                   │
│     TTL: 1 hour                                     │
│                                                     │
│  5. Celery Queue                                    │
│     - Background task queue                         │
│     - Task results                                  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### 5.2.2 Cache Invalidation Strategy

**Time-based expiration:**
- Session cache: 7 days
- Query cache: 5 minutes
- Analytics cache: 1 hour

**Event-based invalidation:**
```python
# When customer is updated
def invalidate_customer_cache(customer_id):
    cache.delete(f'customer:{customer_id}')
    cache.delete_pattern('customer_list:*')
    cache.delete('dashboard_metrics')
```

---

## 6. API Architecture

### 6.1 RESTful API Design

#### 6.1.1 Resource Endpoints

**Base URL:** `https://api.crm.example.com/api/v1`

**Endpoint Structure:**
```
/api/v1/
├── auth/
│   ├── login/              POST   - User login
│   ├── logout/             POST   - User logout
│   ├── refresh/            POST   - Refresh JWT token
│   └── password-reset/     POST   - Password reset
├── users/
│   ├── /                   GET    - List users
│   ├── /                   POST   - Create user
│   ├── /:id/               GET    - Get user
│   ├── /:id/               PUT    - Update user
│   ├── /:id/               DELETE - Delete user
│   └── /me/                GET    - Get current user
├── customers/
│   ├── /                   GET    - List customers
│   ├── /                   POST   - Create customer
│   ├── /:id/               GET    - Get customer
│   ├── /:id/               PUT    - Update customer
│   ├── /:id/               DELETE - Delete customer
│   ├── /:id/orders/        GET    - Get customer orders
│   ├── /:id/activities/    GET    - Get customer activities
│   ├── /:id/tags/          POST   - Add tags
│   ├── /import/            POST   - Import customers (CSV)
│   └── /export/            GET    - Export customers (CSV)
├── orders/
│   ├── /                   GET    - List orders
│   ├── /:id/               GET    - Get order
│   └── /:id/               PUT    - Update order
├── activities/
│   ├── /                   GET    - List activities
│   ├── /                   POST   - Create activity
│   ├── /:id/               GET    - Get activity
│   ├── /:id/               PUT    - Update activity
│   └── /:id/               DELETE - Delete activity
├── analytics/
│   ├── /dashboard/         GET    - Dashboard metrics
│   ├── /customers/growth/  GET    - Customer growth
│   ├── /revenue/country/   GET    - Revenue by country
│   └── /customers/top/     GET    - Top customers
├── integrations/
│   ├── /                   GET    - List integrations
│   ├── /shopify/connect/   GET    - Start Shopify OAuth
│   ├── /shopify/callback/  GET    - Shopify OAuth callback
│   └── /:id/sync/          POST   - Trigger sync
├── templates/
│   ├── /                   GET    - List email templates
│   ├── /                   POST   - Create template
│   ├── /:id/               GET    - Get template
│   └── /:id/               PUT    - Update template
└── webhooks/
    └── /shopify/           POST   - Receive Shopify webhooks
```

#### 6.1.2 Request/Response Format

**Request Headers:**
```
Authorization: Bearer <jwt_access_token>
Content-Type: application/json
Accept: application/json
Accept-Language: en
```

**Success Response:**
```json
{
  "data": {
    "id": "uuid",
    "email": "customer@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "country_code": "US",
    "created_at": "2026-01-19T10:00:00Z"
  },
  "meta": {
    "timestamp": "2026-01-19T10:00:00Z"
  }
}
```

**List Response with Pagination:**
```json
{
  "data": [
    { /* customer 1 */ },
    { /* customer 2 */ }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 25,
      "total": 250,
      "total_pages": 10
    }
  },
  "links": {
    "self": "/api/v1/customers?page=1",
    "next": "/api/v1/customers?page=2",
    "prev": null,
    "first": "/api/v1/customers?page=1",
    "last": "/api/v1/customers?page=10"
  }
}
```

**Error Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "email": ["This field must be a valid email address"],
      "country_code": ["Invalid country code"]
    }
  },
  "meta": {
    "timestamp": "2026-01-19T10:00:00Z"
  }
}
```

#### 6.1.3 Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | BAD_REQUEST | Invalid request format |
| 400 | VALIDATION_ERROR | Data validation failed |
| 401 | UNAUTHORIZED | Missing or invalid authentication |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict (duplicate) |
| 422 | UNPROCESSABLE_ENTITY | Semantic error in request |
| 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| 500 | INTERNAL_SERVER_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |

#### 6.1.4 API Versioning Strategy

- **URL Versioning**: `/api/v1/`, `/api/v2/`
- Major version bump for breaking changes
- Maintain backwards compatibility for at least 6 months
- Deprecation warnings in response headers

#### 6.1.5 Rate Limiting

**Tiers:**
- Anonymous: 100 requests/hour
- Authenticated: 1000 requests/hour
- Admin: 5000 requests/hour

**Headers:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 950
X-RateLimit-Reset: 1642598400
```

### 6.2 API Documentation

- **Tool**: drf-spectacular (OpenAPI 3.0)
- **Auto-generated**: Swagger UI at `/api/docs/`
- **Schema**: OpenAPI JSON at `/api/schema/`

---

## 7. Integration Architecture

### 7.1 Integration Framework

```
┌─────────────────────────────────────────────────────┐
│        Integration Layer                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Base Integration Service (Abstract)                │
│  ├── authenticate()                                 │
│  ├── sync_customers()                               │
│  ├── sync_orders()                                  │
│  ├── handle_webhook()                               │
│  └── transform_data()                               │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  Shopify Service                            │   │
│  │  - OAuth 2.0 authentication                 │   │
│  │  - REST API client                          │   │
│  │  - Webhook receiver                         │   │
│  │  - Rate limit handling                      │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  WooCommerce Service                        │   │
│  │  - API key authentication                   │   │
│  │  - REST API client                          │   │
│  │  - Webhook receiver                         │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  Email Service (SendGrid/AWS SES)           │   │
│  │  - Template rendering                       │   │
│  │  - Send email                               │   │
│  │  - Track delivery                           │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 7.2 Shopify Integration

#### 7.2.1 Authentication Flow

```
1. User clicks "Connect Shopify"
   ↓
2. Redirect to Shopify OAuth:
   https://myshop.myshopify.com/admin/oauth/authorize
   ?client_id=<api_key>
   &scope=read_customers,read_orders
   &redirect_uri=https://crm.example.com/integrations/shopify/callback
   ↓
3. User approves in Shopify
   ↓
4. Shopify redirects to callback with code
   ↓
5. Exchange code for access token
   POST https://myshop.myshopify.com/admin/oauth/access_token
   ↓
6. Store encrypted access token in database
   ↓
7. Register webhooks
```

#### 7.2.2 Data Sync Strategy

**Initial Sync (Celery Task):**
```python
@celery_app.task
def sync_shopify_customers(integration_id):
    integration = Integration.objects.get(id=integration_id)
    service = ShopifyService(integration)

    # Paginate through all customers
    page = 1
    while True:
        customers = service.get_customers(page=page, limit=250)
        if not customers:
            break

        for customer_data in customers:
            # Transform and save
            CustomerService.import_from_shopify(customer_data)

        page += 1
```

**Real-time Updates (Webhooks):**
```python
@api_view(['POST'])
def shopify_webhook(request):
    # Verify webhook signature
    if not verify_shopify_webhook(request):
        return Response(status=401)

    topic = request.headers.get('X-Shopify-Topic')

    # Queue for background processing
    process_shopify_webhook.delay(topic, request.data)

    return Response(status=200)
```

#### 7.2.3 Rate Limiting Handling

```python
class ShopifyService:
    def make_request(self, url):
        while True:
            response = requests.get(url, headers=self.headers)

            if response.status_code == 429:
                # Rate limited - wait and retry
                retry_after = response.headers.get('Retry-After', 2)
                time.sleep(int(retry_after))
                continue

            return response
```

### 7.3 Email Integration

```python
class EmailService:
    def __init__(self):
        self.client = SendGridAPIClient(api_key=settings.SENDGRID_API_KEY)

    def send_email(self, to_email, template_id, variables):
        # Render template
        template = EmailTemplate.objects.get(id=template_id)
        subject = self.render_template(template.subject, variables)
        body = self.render_template(template.body, variables)

        # Send via SendGrid
        message = Mail(
            from_email='noreply@crm.example.com',
            to_emails=to_email,
            subject=subject,
            html_content=body
        )

        # Queue sending
        send_email_task.delay(message.to_json())

        # Log activity
        Activity.objects.create(
            customer_id=variables['customer_id'],
            type='email',
            subject=subject,
            direction='outbound'
        )
```

---

## 8. Security Architecture

### 8.1 Security Layers

```
┌─────────────────────────────────────────────────────┐
│  1. Network Security                                │
│     - HTTPS/TLS 1.3                                 │
│     - Firewall rules                                │
│     - DDoS protection (CloudFlare)                  │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  2. Application Security                            │
│     - CORS configuration                            │
│     - Security headers (CSP, HSTS, etc.)            │
│     - Rate limiting                                 │
│     - Input validation                              │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  3. Authentication & Authorization                  │
│     - JWT tokens                                    │
│     - Role-based access control (RBAC)              │
│     - Password hashing (bcrypt)                     │
│     - MFA (future)                                  │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  4. Data Security                                   │
│     - Encryption at rest (database)                 │
│     - Encryption in transit (TLS)                   │
│     - Encrypted integration credentials             │
│     - Secure file storage                           │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  5. Monitoring & Auditing                           │
│     - Audit logs                                    │
│     - Security event logging                        │
│     - Intrusion detection                           │
│     - Vulnerability scanning                        │
└─────────────────────────────────────────────────────┘
```

### 8.2 Authentication Implementation

```python
# JWT token generation
from rest_framework_simplejwt.tokens import RefreshToken

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Token payload
{
    "token_type": "access",
    "exp": 1642598400,  # 15 minutes from now
    "iat": 1642597500,
    "jti": "abc123",
    "user_id": "uuid",
    "role": "manager"
}
```

### 8.3 Authorization Matrix

| Resource | Admin | Manager | Agent | Read-Only |
|----------|-------|---------|-------|-----------|
| View customers | ✓ | ✓ | ✓ (assigned) | ✓ |
| Create customers | ✓ | ✓ | ✓ | ✗ |
| Edit customers | ✓ | ✓ | ✓ (assigned) | ✗ |
| Delete customers | ✓ | ✓ | ✗ | ✗ |
| View orders | ✓ | ✓ | ✓ | ✓ |
| Manage team | ✓ | ✗ | ✗ | ✗ |
| Manage integrations | ✓ | ✓ | ✗ | ✗ |
| View analytics | ✓ | ✓ | ✓ | ✓ |
| System settings | ✓ | ✗ | ✗ | ✗ |

### 8.4 Data Encryption

**At Rest:**
- Database: PostgreSQL encryption (pgcrypto extension)
- Integration credentials: AES-256 encryption
- File storage: S3 server-side encryption

**In Transit:**
- TLS 1.3 for all HTTP traffic
- Certificate pinning (mobile apps)

### 8.5 GDPR Compliance

```python
class GDPRService:
    @staticmethod
    def export_customer_data(customer_id):
        """Right to access"""
        customer = Customer.objects.get(id=customer_id)
        orders = Order.objects.filter(customer_id=customer_id)
        activities = Activity.objects.filter(customer_id=customer_id)

        return {
            'customer': customer.to_dict(),
            'orders': [o.to_dict() for o in orders],
            'activities': [a.to_dict() for a in activities]
        }

    @staticmethod
    def delete_customer_data(customer_id):
        """Right to be forgotten"""
        customer = Customer.objects.get(id=customer_id)

        # Anonymize instead of delete (for audit trail)
        customer.email = f'deleted_{customer.id}@example.com'
        customer.first_name = 'Deleted'
        customer.last_name = 'User'
        customer.phone = None
        customer.custom_fields = {}
        customer.status = 'deleted'
        customer.save()

        # Delete activities
        Activity.objects.filter(customer_id=customer_id).delete()
```

---

## 9. Deployment Architecture

### 9.1 Production Deployment Diagram

```
                    ┌─────────────────────────┐
                    │   CloudFlare CDN        │
                    │   - Static assets       │
                    │   - DDoS protection     │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │   Load Balancer         │
                    │   (AWS ALB / NGINX)     │
                    └─────┬───────────────┬───┘
                          │               │
          ┌───────────────▼───┐   ┌──────▼────────────┐
          │  Web Server 1     │   │  Web Server 2     │
          │  (Django/Gunicorn)│   │  (Django/Gunicorn)│
          └───────────────────┘   └───────────────────┘
                          │               │
                          └───────┬───────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
┌─────────▼────────┐   ┌──────────▼────────┐   ┌────────▼────────┐
│  PostgreSQL      │   │   Redis           │   │  S3 Storage     │
│  (Primary)       │   │   - Cache         │   │  - Files        │
│  + Read Replica  │   │   - Queue         │   │  - Exports      │
└──────────────────┘   └───────────────────┘   └─────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   Celery Workers (3+)     │
                    │   - Background tasks      │
                    │   - Webhooks              │
                    │   - Email sending         │
                    └───────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Monitoring & Logging                                       │
│  - Sentry (errors)                                          │
│  - CloudWatch / DataDog (metrics)                           │
│  - ELK Stack (logs)                                         │
└─────────────────────────────────────────────────────────────┘
```

### 9.2 Container Architecture (Docker)

```yaml
# docker-compose.yml (production)
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend

  backend:
    build: ./backend
    command: gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 4
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY=${SECRET_KEY}
    depends_on:
      - postgres
      - redis
    deploy:
      replicas: 2

  celery_worker:
    build: ./backend
    command: celery -A config worker -l info --concurrency=4
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - postgres
      - redis
    deploy:
      replicas: 3

  celery_beat:
    build: ./backend
    command: celery -A config beat -l info
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - redis

  postgres:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=crm_db
      - POSTGRES_PASSWORD=${DB_PASSWORD}

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 9.3 CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run backend tests
        run: |
          cd backend
          pip install -r requirements/test.txt
          pytest
      - name: Run frontend tests
        run: |
          cd frontend
          npm install
          npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker images
        run: |
          docker build -t crm-backend:${{ github.sha }} ./backend
          docker build -t crm-frontend:${{ github.sha }} ./frontend
      - name: Push to registry
        run: |
          docker push crm-backend:${{ github.sha }}
          docker push crm-frontend:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          # SSH to production server
          # Pull new images
          # Run database migrations
          # Restart services
```

---

## 10. Scalability Architecture

### 10.1 Horizontal Scaling Strategy

**Application Tier:**
- Stateless Django application servers
- Scale horizontally by adding more containers
- Load balancer distributes traffic

**Database Tier:**
- PostgreSQL with read replicas
- Write to primary, read from replicas
- Connection pooling (PgBouncer)

**Cache Tier:**
- Redis cluster with replication
- Separate Redis instances for cache and queue

**Worker Tier:**
- Scale Celery workers independently
- Queue-based load distribution

### 10.2 Performance Optimization

**Database:**
- Query optimization with Django Debug Toolbar
- Database indexes on frequently queried columns
- Connection pooling
- Read replicas for analytics queries

**API:**
- Response caching in Redis
- Pagination for list endpoints
- Field selection (sparse fieldsets)
- Compression (gzip)

**Frontend:**
- Code splitting
- Lazy loading
- Image optimization
- CDN for static assets
- Bundle size optimization

### 10.3 Load Testing Targets

- **Concurrent Users**: 1,000+
- **Requests per Second**: 500+
- **API Response Time**: < 200ms (p95)
- **Database Query Time**: < 50ms (p95)

---

## 11. Technology Stack Rationale

### 11.1 Why Django?

**Pros:**
- Batteries included (admin, ORM, auth)
- Mature ecosystem
- Django REST Framework for APIs
- Strong security features
- Great for rapid development
- Excellent for data-heavy applications

**Cons:**
- Monolithic (mitigated with modular app structure)
- Not ideal for real-time (acceptable for CRM use case)

### 11.2 Why React?

**Pros:**
- Component-based architecture
- Large ecosystem
- TypeScript support
- Virtual DOM performance
- Wide adoption (easy to hire)

**Cons:**
- Larger bundle size (mitigated with code splitting)
- Complex state management (using Zustand, not Redux)

### 11.3 Why PostgreSQL?

**Pros:**
- ACID compliance
- JSON support (custom_fields)
- Excellent performance
- Advanced indexing (GIN for JSONB)
- Strong community

**Cons:**
- Vertical scaling limits (acceptable for target scale)

### 11.4 Why Redis?

**Pros:**
- In-memory speed
- Multiple data structures
- Pub/sub for real-time features
- Celery integration

**Cons:**
- Memory-bound (acceptable with expiration policies)

---

## 12. Design Patterns

### 12.1 Backend Patterns

**1. Service Layer Pattern:**
```python
# Business logic in services, not views
class CustomerService:
    @staticmethod
    def create_customer(data):
        # Validation
        # Business logic
        # Database operations
        return customer
```

**2. Repository Pattern (Django ORM):**
```python
# Django ORM acts as repository
customers = Customer.objects.filter(country='US').order_by('-created_at')
```

**3. Factory Pattern (Serializers):**
```python
def get_serializer_class(self):
    if self.action == 'list':
        return CustomerListSerializer
    return CustomerDetailSerializer
```

**4. Strategy Pattern (Integration Services):**
```python
class IntegrationService(ABC):
    @abstractmethod
    def sync_customers(self):
        pass

class ShopifyService(IntegrationService):
    def sync_customers(self):
        # Shopify-specific implementation
```

### 12.2 Frontend Patterns

**1. Component Composition:**
```tsx
<CustomerDetail>
  <CustomerProfile />
  <CustomerOrders />
  <CustomerActivities />
</CustomerDetail>
```

**2. Custom Hooks:**
```tsx
function useCustomer(customerId) {
  const [customer, setCustomer] = useState(null);
  // Fetch logic
  return { customer, loading, error };
}
```

**3. Render Props / Compound Components:**
```tsx
<Table>
  <Table.Header>
    <Table.Row>
      <Table.Cell>Name</Table.Cell>
    </Table.Row>
  </Table.Header>
</Table>
```

---

## 13. Development Architecture

### 13.1 Development Environment

```
┌──────────────────────────────────────────────────┐
│  Developer Machine                               │
│  ┌────────────────────────────────────────────┐  │
│  │  VS Code / IDE                             │  │
│  │  - Python extension                        │  │
│  │  - ESLint, Prettier                        │  │
│  │  - Docker extension                        │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │  Docker Compose (local)                    │  │
│  │  ├── PostgreSQL:5432                       │  │
│  │  ├── Redis:6379                            │  │
│  │  ├── Backend:8000 (hot reload)             │  │
│  │  ├── Frontend:5173 (Vite dev server)       │  │
│  │  └── Celery Worker                         │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │  Git + Pre-commit Hooks                    │  │
│  │  - Black (Python formatting)               │  │
│  │  - isort (import sorting)                  │  │
│  │  - flake8 (linting)                        │  │
│  │  - ESLint + Prettier (JS/TS)               │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

### 13.2 Code Organization Principles

**Backend:**
- Django apps organized by domain (customers, orders, etc.)
- Service layer for business logic
- Thin views/viewsets
- Comprehensive tests alongside code

**Frontend:**
- Feature-based organization
- Shared components library
- Co-located tests
- Type-safe with TypeScript

---

## 14. Monitoring and Observability

### 14.1 Monitoring Stack

```
┌─────────────────────────────────────────────────┐
│  Application Monitoring                         │
│  - Sentry (error tracking)                      │
│  - APM (performance monitoring)                 │
│  - User analytics                               │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Infrastructure Monitoring                      │
│  - CloudWatch / DataDog                         │
│  - Server metrics (CPU, memory, disk)           │
│  - Database metrics                             │
│  - Redis metrics                                │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Logging                                        │
│  - Centralized logging (ELK Stack)              │
│  - Structured JSON logs                         │
│  - Log retention: 90 days                       │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Alerting                                       │
│  - PagerDuty / OpsGenie                         │
│  - Slack notifications                          │
│  - Email alerts                                 │
└─────────────────────────────────────────────────┘
```

### 14.2 Key Metrics

**Application Metrics:**
- API response time (p50, p95, p99)
- Error rate
- Request rate
- Active users

**Business Metrics:**
- New customers per day
- Orders per day
- Revenue tracked

**Infrastructure Metrics:**
- CPU usage
- Memory usage
- Disk I/O
- Network I/O

---

## 15. Disaster Recovery and Backup

### 15.1 Backup Strategy

**Database:**
- Automated daily backups (full)
- Continuous archiving (WAL)
- Retention: 30 days
- Cross-region replication

**Files (S3):**
- Versioning enabled
- Cross-region replication
- Lifecycle policies

**Application Configuration:**
- Version controlled in Git
- Secrets in encrypted vault

### 15.2 Recovery Procedures

**Database Recovery:**
1. Identify recovery point
2. Restore from backup
3. Apply WAL logs (point-in-time recovery)
4. Verify data integrity
5. Switch traffic

**RTO**: < 4 hours
**RPO**: < 1 hour

---

## 16. Architecture Decision Records

### ADR-001: Use Django Instead of FastAPI

**Status:** Accepted

**Context:** Need to choose Python web framework

**Decision:** Use Django + Django REST Framework

**Rationale:**
- Built-in admin panel for internal tools
- ORM is more feature-rich than SQLAlchemy
- Batteries included (auth, migrations, etc.)
- Team has Django experience
- Faster development for data-heavy applications

**Consequences:**
- Slightly higher overhead than FastAPI
- Less modern async support (acceptable for use case)

---

### ADR-002: Use Zustand Instead of Redux

**Status:** Accepted

**Context:** Need state management for React

**Decision:** Use Zustand

**Rationale:**
- Simpler API than Redux
- Less boilerplate
- Smaller bundle size
- Sufficient for application complexity
- Easy to migrate to Redux if needed

**Consequences:**
- Less ecosystem support than Redux
- Team needs to learn new library

---

### ADR-003: Monolithic Architecture Initially

**Status:** Accepted

**Context:** Choose between monolith vs microservices

**Decision:** Start with monolithic Django application

**Rationale:**
- Faster initial development
- Easier to reason about
- Suitable for team size and scale
- Can extract services later if needed
- Avoid premature optimization

**Consequences:**
- Harder to scale specific components independently
- All code in one deployment unit

---

## Document Control

**Version**: 1.0
**Date**: 2026-01-19
**Author**: Technical Architect
**Status**: Final

### Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Technical Lead | | | |
| Security Lead | | | |
| DevOps Lead | | | |

### Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-19 | Technical Architect | Initial architecture document |

---

## References

- Django Documentation: https://docs.djangoproject.com/
- Django REST Framework: https://www.django-rest-framework.org/
- React Documentation: https://react.dev/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Redis Documentation: https://redis.io/documentation
- Shopify API: https://shopify.dev/docs/api
- OWASP Security Guidelines: https://owasp.org/
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/
