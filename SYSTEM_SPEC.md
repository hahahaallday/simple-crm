# Simple CRM System Specification
## Cross-Border Ecommerce SaaS

---

## 1. Executive Summary

This document outlines the system specification for a lightweight CRM designed specifically for cross-border ecommerce businesses. The system focuses on managing customer relationships across multiple countries, currencies, and languages while maintaining simplicity and ease of use.

### 1.1 Goals
- Centralize customer data across international markets
- Enable efficient customer communication and support
- Track customer lifecycle and purchase behavior
- Support multi-currency, multi-language operations
- Provide actionable insights for cross-border sales

---

## 2. System Overview

### 2.1 Core Purpose
A simple, scalable CRM that helps cross-border ecommerce teams manage customer relationships, track interactions, and drive repeat purchases across international markets.

### 2.2 Target Users
- Customer support teams
- Sales/account managers
- Marketing teams
- Operations teams managing cross-border logistics

### 2.3 Key Differentiators
- Built-in cross-border capabilities (currency, language, timezone)
- Ecommerce-focused customer journey tracking
- Simplified interface optimized for speed
- Integration-ready for common ecommerce platforms

---

## 3. Core Modules

### 3.1 Customer Management

#### Features
- **Customer Profiles**
  - Basic info (name, email, phone, company)
  - Geographic data (country, region, timezone)
  - Language preference
  - Currency preference
  - Tags and segments
  - Custom fields support
  - Account status (active, inactive, VIP, blocked)

- **Contact History**
  - Timeline view of all interactions
  - Notes and attachments
  - Activity log (emails, calls, chat, meetings)
  - Automated activity capture from integrations

- **Customer Segmentation**
  - Dynamic segments based on attributes
  - Behavioral segments (purchase history, engagement)
  - Geographic segments
  - Value-based segments (LTV, AOV)

#### Data Fields
```
Customer {
  id: UUID
  created_at: DateTime
  updated_at: DateTime

  // Basic Info
  first_name: String
  last_name: String
  email: String (unique, indexed)
  phone: String
  company_name: String?

  // Geographic
  country_code: String (ISO 3166-1)
  region: String?
  city: String?
  postal_code: String?
  timezone: String (IANA timezone)

  // Preferences
  language: String (ISO 639-1)
  currency: String (ISO 4217)

  // Status
  status: Enum (active, inactive, vip, blocked)
  tags: Array<String>
  custom_fields: JSON

  // Metrics
  lifetime_value: Decimal
  total_orders: Integer
  average_order_value: Decimal
  last_order_date: DateTime?
  first_order_date: DateTime?
}
```

### 3.2 Order Management

#### Features
- **Order Tracking**
  - Link orders to customers
  - Order status tracking
  - Multi-currency order values
  - Shipping information
  - Payment status
  - Returns and refunds tracking

- **Purchase History**
  - Chronological order list per customer
  - Product purchase history
  - Revenue attribution
  - Order frequency analysis

#### Data Fields
```
Order {
  id: UUID
  customer_id: UUID (FK)
  created_at: DateTime
  updated_at: DateTime

  // Order Details
  order_number: String (unique, indexed)
  status: Enum (pending, processing, shipped, delivered, cancelled, refunded)

  // Financial
  total_amount: Decimal
  currency: String (ISO 4217)
  total_amount_usd: Decimal (normalized)
  tax_amount: Decimal
  shipping_amount: Decimal

  // Shipping
  shipping_country: String
  shipping_address: JSON
  tracking_number: String?
  carrier: String?
  shipped_at: DateTime?
  delivered_at: DateTime?

  // Products
  items: Array<OrderItem>

  // Metadata
  source: String (website, marketplace, app)
  notes: Text?
}

OrderItem {
  id: UUID
  order_id: UUID (FK)
  product_id: String
  product_name: String
  quantity: Integer
  unit_price: Decimal
  total_price: Decimal
  sku: String?
}
```

### 3.3 Communication Hub

#### Features
- **Email Management**
  - Send emails from CRM
  - Email templates with multi-language support
  - Email tracking (opens, clicks)
  - Thread view of email conversations
  - Integration with email services

- **Activity Logging**
  - Manual activity creation (calls, meetings, notes)
  - Automatic activity capture
  - Task assignment and follow-ups
  - Reminders and notifications

- **Templates**
  - Email templates
  - Response templates
  - Multi-language template variants
  - Variable substitution (name, order number, etc.)

#### Data Fields
```
Activity {
  id: UUID
  customer_id: UUID (FK)
  user_id: UUID (FK - team member)
  created_at: DateTime

  // Activity Details
  type: Enum (email, call, meeting, note, task)
  subject: String
  description: Text
  direction: Enum (inbound, outbound)

  // Status (for tasks)
  status: Enum (pending, completed, cancelled)?
  due_date: DateTime?

  // Email specific
  email_metadata: JSON? {
    from: String
    to: Array<String>
    cc: Array<String>?
    opened: Boolean
    clicked: Boolean
    opened_at: DateTime?
  }

  // Attachments
  attachments: Array<String> (file URLs)
}
```

### 3.4 Analytics & Reports

#### Features
- **Customer Analytics**
  - Customer acquisition trends
  - Geographic distribution
  - Customer lifetime value analysis
  - Churn analysis
  - Cohort analysis

- **Sales Analytics**
  - Revenue by country/region
  - Currency-normalized reporting
  - Order trends and seasonality
  - Product performance
  - Average order value trends

- **Team Performance**
  - Activity metrics per user
  - Response time tracking
  - Resolution metrics
  - Workload distribution

#### Standard Reports
1. Customer Growth Report (by country, time period)
2. Revenue by Country Report
3. Top Customers Report (by LTV, order count)
4. Customer Segmentation Report
5. Activity Summary Report
6. Churn Risk Report

### 3.5 User Management

#### Features
- **Team Member Accounts**
  - User authentication and authorization
  - Role-based access control
  - Profile management
  - Activity tracking

- **Roles & Permissions**
  - Admin (full access)
  - Manager (view all, edit all, limited settings)
  - Agent (view assigned, edit assigned)
  - Read-only (view only)

#### Data Fields
```
User {
  id: UUID
  created_at: DateTime
  updated_at: DateTime

  // Auth
  email: String (unique, indexed)
  password_hash: String

  // Profile
  first_name: String
  last_name: String
  avatar_url: String?
  timezone: String
  language: String

  // Access
  role: Enum (admin, manager, agent, readonly)
  status: Enum (active, inactive)
  last_login: DateTime?
}
```

---

## 4. Technical Architecture

### 4.1 System Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Frontend Layer                        │
│  - Web Application (React/Vue)                           │
│  - Mobile-responsive design                              │
│  - Real-time updates via WebSockets                      │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                    API Layer (REST)                      │
│  - Authentication & Authorization                        │
│  - Rate limiting                                         │
│  - Input validation                                      │
│  - API versioning                                        │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  Business Logic Layer                    │
│  - Customer management service                           │
│  - Order management service                              │
│  - Communication service                                 │
│  - Analytics service                                     │
│  - Integration service                                   │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                            │
│  - Primary Database (PostgreSQL)                         │
│  - Cache Layer (Redis)                                   │
│  - Search Engine (Elasticsearch) [Optional]              │
│  - File Storage (S3 or equivalent)                       │
└─────────────────────────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  Integration Layer                       │
│  - Ecommerce platforms (Shopify, WooCommerce, etc.)     │
│  - Email services (SendGrid, AWS SES)                   │
│  - Analytics platforms                                   │
│  - Shipping carriers                                     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Technology Stack Recommendations

#### Backend
- **Runtime**: Node.js or Python
- **Framework**: Express.js / FastAPI / Django
- **Database**: PostgreSQL (primary), Redis (cache)
- **Search**: Elasticsearch (optional, for large datasets)
- **Queue**: Redis / RabbitMQ / AWS SQS (for async jobs)

#### Frontend
- **Framework**: React / Vue.js
- **State Management**: Redux / Vuex / Zustand
- **UI Library**: Tailwind CSS / Material-UI
- **Charts**: Chart.js / Recharts

#### Infrastructure
- **Hosting**: AWS / GCP / DigitalOcean
- **CDN**: CloudFlare
- **Monitoring**: Sentry, DataDog, or New Relic
- **Email**: SendGrid / AWS SES
- **File Storage**: AWS S3 / GCS

---

## 4.3 Selected Technology Stack

Based on project requirements for rapid development, scalability, and cross-border ecommerce features, the following stack has been selected:

### Backend (Supabase)
- **Platform**: Supabase (Backend-as-a-Service)
- **Database**: PostgreSQL 15+ (managed by Supabase)
- **API**: Auto-generated REST API (PostgREST)
- **Real-time**: Built-in real-time subscriptions via WebSockets
- **Authentication**: Supabase Auth (JWT-based)
- **Storage**: Supabase Storage (file uploads, avatars, exports)
- **Edge Functions**: Deno-based serverless functions for custom logic
- **Row Level Security (RLS)**: Database-level security policies

**Why Supabase:**
- ✅ Instant REST API from database schema
- ✅ Built-in authentication with JWT
- ✅ Real-time subscriptions out of the box
- ✅ Row-level security for fine-grained access control
- ✅ Managed PostgreSQL with automatic backups
- ✅ No backend infrastructure to maintain
- ✅ Generous free tier, scales automatically
- ✅ TypeScript SDK for frontend integration

**Supabase Features Used:**
```typescript
// Supabase client initialization
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.VITE_SUPABASE_ANON_KEY
)
```

### Edge Functions (for Custom Business Logic)
- **Runtime**: Deno (TypeScript/JavaScript)
- **Use Cases**:
  - Shopify webhook processing
  - Email sending via SendGrid
  - Currency conversion
  - Complex analytics calculations
  - Scheduled tasks (cron jobs)

**Key Edge Functions:**
```
supabase/functions/
├── shopify-sync/           # Sync customers and orders from Shopify
├── shopify-webhook/        # Process Shopify webhooks
├── send-email/             # Send emails via SendGrid
├── calculate-analytics/    # Generate analytics data
└── scheduled-sync/         # Daily/hourly sync tasks
```

### Frontend
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite (faster than Create React App)
- **State Management**: Zustand (lightweight, simpler than Redux)
- **UI Components**: Tailwind CSS + shadcn/ui
- **HTTP Client**: Supabase JS Client (replaces Axios)
- **Routing**: React Router v6
- **Form Handling**: React Hook Form + Zod validation
- **Charts**: Recharts
- **Date Utilities**: date-fns with timezone support
- **Icons**: lucide-react

**Key NPM Packages:**
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.1",
    "@supabase/supabase-js": "^2.39.0",
    "zustand": "^4.4.7",
    "react-hook-form": "^7.49.3",
    "zod": "^3.22.4",
    "@hookform/resolvers": "^3.3.4",
    "recharts": "^2.10.3",
    "date-fns": "^3.0.6",
    "date-fns-tz": "^2.0.0",
    "tailwindcss": "^3.4.1",
    "@radix-ui/react-dialog": "^1.0.5",
    "@radix-ui/react-dropdown-menu": "^2.0.6",
    "@radix-ui/react-select": "^2.0.0",
    "lucide-react": "^0.303.0"
  }
}
```

### Development Environment
- **Version Control**: Git + GitHub
- **Development**: Vite dev server with HMR
- **Testing**: Vitest + React Testing Library (frontend), Deno test (Edge Functions)
- **Code Quality**: ESLint + Prettier (TypeScript)
- **Database Migrations**: Supabase CLI for migration management

### Integration Services
- **Ecommerce**: Shopify (via Edge Functions)
- **Email**: SendGrid (via Edge Functions)
- **File Storage**: Supabase Storage (built-in)
- **Monitoring**: Sentry (error tracking)

### Project Structure
```
simple-crm/
├── supabase/                   # Supabase configuration
│   ├── config.toml            # Supabase project config
│   ├── migrations/            # Database migrations
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_rls_policies.sql
│   │   └── 003_create_functions.sql
│   ├── functions/             # Edge Functions (Deno)
│   │   ├── shopify-sync/
│   │   │   └── index.ts
│   │   ├── shopify-webhook/
│   │   │   └── index.ts
│   │   ├── send-email/
│   │   │   └── index.ts
│   │   ├── calculate-analytics/
│   │   │   └── index.ts
│   │   └── _shared/          # Shared utilities
│   │       ├── supabase.ts
│   │       └── types.ts
│   └── seed.sql               # Seed data for development
│
├── frontend/                   # React app
│   ├── src/
│   │   ├── components/        # Reusable UI components
│   │   ├── features/          # Feature-specific components
│   │   │   ├── customers/
│   │   │   ├── orders/
│   │   │   ├── activities/
│   │   │   ├── analytics/
│   │   │   └── settings/
│   │   ├── layouts/           # Page layouts
│   │   ├── pages/             # Page components
│   │   ├── hooks/             # Custom React hooks
│   │   │   ├── useSupabase.ts
│   │   │   ├── useAuth.ts
│   │   │   └── useRealtime.ts
│   │   ├── store/             # Zustand stores
│   │   ├── lib/               # Supabase client setup
│   │   │   └── supabase.ts
│   │   ├── utils/             # Utility functions
│   │   ├── types/             # TypeScript types
│   │   │   └── database.ts    # Auto-generated from Supabase
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── tailwind.config.js
│
├── .env.example
├── .gitignore
└── README.md
```

---

### 4.4 Database Schema Overview

#### Core Tables
1. `customers` - Customer master data
2. `orders` - Order records
3. `order_items` - Order line items
4. `activities` - Customer interactions and activities
5. `users` - Team member accounts
6. `tags` - Customer tags
7. `customer_tags` - Many-to-many relationship
8. `segments` - Saved customer segments
9. `templates` - Email and communication templates
10. `integrations` - Connected platform credentials
11. `webhooks` - Webhook configurations

#### Indexes
- `customers.email` (unique)
- `customers.country_code`
- `customers.created_at`
- `orders.customer_id`
- `orders.order_number` (unique)
- `orders.created_at`
- `activities.customer_id`
- `activities.created_at`
- `users.email` (unique)

---

## 5. Integration Requirements

### 5.1 Ecommerce Platform Integrations

#### Priority 1
- **Shopify**
  - Sync customers
  - Sync orders (real-time via webhooks)
  - Sync products

- **WooCommerce**
  - REST API integration
  - Webhook support

#### Priority 2
- Amazon Seller Central
- eBay
- Custom API integration

### 5.2 Communication Integrations

- **Email Services**
  - SendGrid
  - AWS SES
  - SMTP support

- **Future considerations**
  - WhatsApp Business API
  - SMS gateway integration
  - Live chat integration

### 5.3 Data Integration Methods

1. **Real-time**: Webhooks for order creation, customer updates
2. **Batch**: Scheduled sync for historical data (daily/hourly)
3. **API**: REST APIs for manual triggers and on-demand sync

---

## 6. Security & Compliance

### 6.1 Security Requirements

- **Authentication**
  - JWT-based authentication
  - Password hashing (bcrypt)
  - MFA support (TOTP)
  - Session management with expiry

- **Authorization**
  - Role-based access control (RBAC)
  - Resource-level permissions
  - API key management for integrations

- **Data Security**
  - Encryption at rest (database)
  - Encryption in transit (TLS 1.3)
  - PII data protection
  - Secure file uploads (virus scanning)

- **Security Practices**
  - Input validation and sanitization
  - SQL injection prevention (parameterized queries)
  - XSS prevention
  - CSRF protection
  - Rate limiting to prevent abuse

### 6.2 Compliance

- **GDPR Compliance**
  - Right to access (data export)
  - Right to deletion (data removal)
  - Consent management
  - Data processing agreements
  - Privacy policy

- **Data Residency**
  - Support for regional data storage
  - EU data stays in EU (if required)

- **Audit Trail**
  - Log all data access and modifications
  - User activity logging
  - Data retention policies

---

## 7. Non-Functional Requirements

### 7.1 Performance

- **Response Time**
  - API responses < 200ms (p95)
  - Page load time < 2 seconds
  - Search results < 500ms

- **Scalability**
  - Support 100,000+ customers
  - Support 1,000+ concurrent users
  - Handle 1000+ orders per hour

- **Database Performance**
  - Optimized queries with proper indexing
  - Connection pooling
  - Query result caching

### 7.2 Availability

- **Uptime**: 99.9% availability (8.76 hours downtime/year)
- **Backup**: Daily automated backups with 30-day retention
- **Disaster Recovery**: RTO < 4 hours, RPO < 1 hour

### 7.3 Usability

- **Multi-language Support**
  - UI available in: English, Spanish, French, German, Chinese
  - Easy language switching
  - RTL support for Arabic, Hebrew (future)

- **Accessibility**
  - WCAG 2.1 Level AA compliance
  - Keyboard navigation
  - Screen reader support

- **Mobile Responsiveness**
  - Fully responsive design
  - Mobile-first approach
  - Touch-friendly interface

### 7.4 Monitoring & Observability

- **Application Monitoring**
  - Error tracking and alerting
  - Performance monitoring (APM)
  - Uptime monitoring

- **Logging**
  - Centralized logging
  - Log retention: 90 days
  - Structured logging (JSON format)

- **Metrics**
  - Business metrics dashboard
  - System health metrics
  - User analytics

---

## 8. API Design

### 8.1 RESTful API Endpoints

#### Customers
```
GET    /api/v1/customers              - List customers (with pagination, filters)
POST   /api/v1/customers              - Create customer
GET    /api/v1/customers/:id          - Get customer details
PUT    /api/v1/customers/:id          - Update customer
DELETE /api/v1/customers/:id          - Delete customer
GET    /api/v1/customers/:id/orders   - Get customer orders
GET    /api/v1/customers/:id/activities - Get customer activities
POST   /api/v1/customers/:id/tags     - Add tags to customer
GET    /api/v1/customers/export       - Export customers (CSV/JSON)
```

#### Orders
```
GET    /api/v1/orders                 - List orders
POST   /api/v1/orders                 - Create order
GET    /api/v1/orders/:id             - Get order details
PUT    /api/v1/orders/:id             - Update order
```

#### Activities
```
GET    /api/v1/activities             - List activities
POST   /api/v1/activities             - Create activity
GET    /api/v1/activities/:id         - Get activity details
PUT    /api/v1/activities/:id         - Update activity
DELETE /api/v1/activities/:id         - Delete activity
```

#### Users
```
GET    /api/v1/users                  - List team members
POST   /api/v1/users                  - Create user
GET    /api/v1/users/:id              - Get user details
PUT    /api/v1/users/:id              - Update user
DELETE /api/v1/users/:id              - Deactivate user
```

#### Analytics
```
GET    /api/v1/analytics/customers    - Customer analytics
GET    /api/v1/analytics/revenue      - Revenue analytics
GET    /api/v1/analytics/geographic   - Geographic distribution
```

### 8.2 API Features

- **Pagination**: Cursor-based or offset pagination
- **Filtering**: Query parameters for filtering (e.g., `?country=US&status=active`)
- **Sorting**: Query parameter for sorting (e.g., `?sort=-created_at`)
- **Field Selection**: Sparse fieldsets (e.g., `?fields=id,name,email`)
- **Search**: Full-text search (e.g., `?q=john`)
- **Rate Limiting**: 1000 requests per hour per API key

### 8.3 Webhooks

Allow external systems to subscribe to events:

#### Available Events
- `customer.created`
- `customer.updated`
- `customer.deleted`
- `order.created`
- `order.updated`
- `order.status_changed`

#### Webhook Payload
```json
{
  "event": "customer.created",
  "timestamp": "2026-01-19T12:00:00Z",
  "data": {
    "id": "uuid",
    "email": "customer@example.com",
    ...
  }
}
```

---

## 9. User Interface Design

### 9.1 Key Pages

1. **Dashboard**
   - Key metrics overview
   - Recent activities
   - Quick actions

2. **Customers List**
   - Searchable/filterable table
   - Bulk actions
   - Export functionality

3. **Customer Detail**
   - Customer profile (left sidebar)
   - Timeline/activity feed (main area)
   - Quick actions (top right)
   - Tabs: Overview, Orders, Activities, Notes

4. **Orders List**
   - Searchable/filterable table
   - Order status visualization
   - Link to customer

5. **Order Detail**
   - Order information
   - Items list
   - Shipping tracking
   - Customer link

6. **Analytics**
   - Charts and graphs
   - Date range selector
   - Export reports

7. **Settings**
   - User profile
   - Team management
   - Integrations
   - Templates
   - System settings

### 9.2 Navigation

```
├─ Dashboard
├─ Customers
├─ Orders
├─ Activities
├─ Analytics
└─ Settings
   ├─ Profile
   ├─ Team
   ├─ Integrations
   ├─ Templates
   └─ System
```

---

## 10. Implementation Phases

This section outlines a phased approach to building the complete CRM system. The full implementation is planned for approximately 24 weeks (6 months) with 20 distinct phases. See the detailed Implementation Plan document for comprehensive week-by-week breakdown.

### Overview of Major Phases

### Phase 0: Project Setup (Week 1)
**Goal**: Establish development environment and project foundation

**Key Tasks:**
- Create Supabase project (hosted or local)
- Install Supabase CLI for local development
- Initialize React + TypeScript project with Vite
- Set up Supabase client in frontend
- Configure environment variables
- Initialize Git repository
- Set up project structure

**Deliverables:**
- Fully configured Supabase project
- React frontend connected to Supabase
- Hot reload for frontend
- README with setup instructions

### Phase 1-2: Database Schema & Authentication (Week 2-3)
**Goal**: Create database schema and set up authentication

**Key Tasks:**
- Design and create database schema (SQL migrations)
  - customers, orders, order_items, activities, users tables
  - Add indexes and constraints
- Configure Supabase Auth with JWT
- Set up Row Level Security (RLS) policies
  - Admin can see/edit everything
  - Managers can see all, edit assigned
  - Agents can only see assigned customers
  - Read-only can only view
- Create database functions for common operations
- Test API endpoints (auto-generated by Supabase)

**Deliverables:**
- Complete database schema with RLS
- Authentication system with role-based access
- Auto-generated REST API endpoints
- Database migration files

### Phase 3-4: Frontend Foundation & Customer UI (Week 4-5)
**Goal**: Build core UI components and customer management interface

**Key Tasks:**
- Create authentication UI (login, password reset)
- Build main layout with sidebar navigation
- Develop reusable UI components (Button, Input, Table, Modal, etc.)
- Implement customer list with search and filters
- Create customer detail page with tabs
- Add customer creation and editing

**Deliverables:**
- Fully functional customer management UI
- Protected routes and auth flow
- Responsive design for mobile

### Phase 5-6: Activities & Orders UI (Week 5-6)
**Goal**: Enable activity tracking and order viewing

**Key Tasks:**
- Extend database schema for activities (if needed)
- Build activity timeline component with real-time updates
- Add activity creation modal
- Implement order list and detail pages
- Link orders to customers
- Add file attachments (Supabase Storage)

**Deliverables:**
- Activity tracking functionality with real-time sync
- Order management UI
- File attachment support via Supabase Storage

### Phase 7-8: Shopify Integration & Email (Week 7-9)
**Goal**: Sync data from Shopify and enable email communication

**Key Tasks:**
- Create Edge Function for Shopify OAuth flow
- Create Edge Function for syncing customers and orders
- Create Edge Function for Shopify webhook receiver
- Set up Supabase cron jobs for scheduled sync
- Create email_templates table
- Create Edge Function for sending emails via SendGrid
- Add email template UI and sending modal

**Deliverables:**
- Working Shopify integration via Edge Functions
- Real-time webhook processing
- Email sending capability

### Phase 9-11: Analytics & Advanced Features (Week 9-13)
**Goal**: Add analytics dashboard and power user features

**Key Tasks:**
- Create database views for analytics queries
- Create Edge Function for calculating complex analytics
- Build dashboard with key metrics and charts
- Implement customer segmentation builder
- Add tag management
- Build bulk operations (add tags, export)
- Add CSV import/export
- Create team management UI

**Deliverables:**
- Analytics dashboard
- Customer segmentation
- Bulk operations
- Team management

### Phase 12-13: Testing & Security (Week 13-15)
**Goal**: Comprehensive testing and security hardening

**Key Tasks:**
- Write comprehensive tests for Edge Functions (Deno test)
- Add frontend component and integration tests
- Review and optimize RLS policies
- Implement GDPR compliance features (data export, deletion)
- Create audit_logs table and triggers
- Configure Supabase API rate limiting
- Security scanning and penetration testing
- Input validation with Zod schemas

**Deliverables:**
- Test coverage >80%
- Secure RLS policies
- GDPR-compliant features
- Security audit completed
- Audit trail system

### Phase 14-15: Performance & Deployment (Week 15-17)
**Goal**: Optimize performance and deploy to production

**Key Tasks:**
- Database query optimization (indexes, views)
- Optimize database functions and RLS policies
- Frontend code splitting and lazy loading
- Set up production Supabase project
- Configure CI/CD pipeline (GitHub Actions for frontend, Supabase for Edge Functions)
- Set up monitoring (Sentry + Supabase logs)
- Configure automated backups (built-in with Supabase)
- Write comprehensive documentation

**Deliverables:**
- Production deployment on Supabase
- API response time <200ms (p95)
- CI/CD pipeline
- Complete documentation

### Phase 16-20: Advanced Features (Week 17-24)
**Goal**: Add additional integrations, automation, and ML features

**Key Tasks:**
- Create Edge Function for WooCommerce integration
- Build workflow automation using database triggers and Edge Functions
- Mobile optimization and PWA support
- Implement customer health scoring (Edge Function + database view)
- Add predictive analytics (churn prediction, LTV) via Edge Functions
- RFM analysis using database views
- Final testing and polish

**Deliverables:**
- Multiple integrations via Edge Functions
- Workflow automation with triggers
- PWA support
- ML-powered insights
- Production-ready system

---

## 11. Detailed Implementation Roadmap

For the complete week-by-week implementation plan with specific tasks, files, and verification steps, refer to the separate **Implementation Plan** document which includes:

- 20 detailed phases with specific tasks
- Critical files to be created/modified
- Database schema with migrations
- Testing strategy for each phase
- Security checklist
- Performance targets
- Deployment architecture
- Environment variable configuration
- Risk mitigation strategies
- Success criteria

**Estimated Total Duration**: 24 weeks (6 months) for complete implementation of all phases
**MVP Launch**: Week 12 (Phase 1-3)
**Full Production Launch**: Week 24 (All phases)

---

## 12. Success Metrics

### Product Metrics
- Monthly Active Users (MAU)
- Daily Active Users (DAU)
- User retention rate
- Time to first value (TTFV)
- Feature adoption rates

### Performance Metrics
- API response time (p95, p99)
- Page load time
- Uptime percentage
- Error rate

### Business Metrics
- Customer satisfaction (CSAT)
- Net Promoter Score (NPS)
- Customer Lifetime Value through CRM usage
- Reduction in customer support resolution time

---

## 13. Future Considerations

### Potential Enhancements
- AI-powered customer insights and recommendations
- Predictive analytics for customer behavior
- Conversational AI chatbot for customer data queries
- Advanced workflow automation builder
- Integration marketplace
- Mobile native apps (iOS, Android)
- Voice of customer (VoC) analysis
- Social media integration
- Multi-brand support for large enterprises

### Technical Evolution
- Microservices architecture (if scale requires)
- GraphQL API (in addition to REST)
- Real-time collaboration features
- Offline-first mobile experience

---

## 14. Appendix

### A. Glossary

- **LTV**: Lifetime Value - total revenue from a customer
- **AOV**: Average Order Value
- **CSAT**: Customer Satisfaction Score
- **NPS**: Net Promoter Score
- **RBAC**: Role-Based Access Control
- **GDPR**: General Data Protection Regulation
- **ISO 3166-1**: International standard for country codes
- **ISO 639-1**: International standard for language codes
- **ISO 4217**: International standard for currency codes

### B. Reference Standards

- ISO 3166-1 Alpha-2 country codes
- ISO 639-1 language codes
- ISO 4217 currency codes
- IANA timezone database
- REST API best practices
- OWASP security guidelines
- WCAG 2.1 accessibility guidelines

### C. Dependencies

#### External Services
- Email delivery service (SendGrid, AWS SES)
- Cloud storage (AWS S3, GCS)
- Authentication service (optional: Auth0, Okta)
- Payment gateway (for future billing)
- Analytics service (optional: Segment, Mixpanel)

#### Third-party Libraries
- Currency conversion API
- Address validation service
- Translation service (for multi-language content)

---

## Document Control

**Version**: 3.0
**Date**: 2026-01-21
**Author**: CPO, Cross-Border Ecommerce SaaS
**Status**: Ready for Implementation

### Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-19 | CPO | Initial system specification |
| 2.0 | 2026-01-19 | CPO | Added selected technology stack (Django + React), detailed project structure, updated implementation phases with 24-week roadmap |
| 3.0 | 2026-01-21 | CPO | **Major Update**: Replaced Django backend with Supabase (BaaS). Updated architecture to use Supabase PostgreSQL, auto-generated REST API, Edge Functions (Deno), Supabase Auth, Storage, and RLS. Updated all implementation phases accordingly. |

