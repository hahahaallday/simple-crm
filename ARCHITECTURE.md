# System Architecture Document
## Cross-Border Ecommerce CRM (Supabase Backend)

**Version**: 2.0
**Date**: 2026-01-21
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

This document describes the technical architecture of the Cross-Border Ecommerce CRM system built on **Supabase** as a Backend-as-a-Service (BaaS) platform. It provides a comprehensive view of the system's structure, components, interactions, and design decisions.

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
└────────────────────────────────────────────────────────────────┘
                            ↓ ↑
┌────────────────────────────────────────────────────────────────┐
│                    CRM System (Supabase)                       │
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
3. **Reliability**: 99.9% uptime (managed by Supabase SLA)
4. **Security**: Enterprise-grade security with GDPR compliance
5. **Maintainability**: Minimal backend code, leverage Supabase built-ins
6. **Extensibility**: Easy to add new integrations via Edge Functions
7. **Cross-Border Ready**: Built-in multi-currency, multi-language support
8. **Cost-Effective**: Generous free tier, pay-as-you-grow pricing

### 2.2 Architectural Principles

1. **BaaS-First**: Leverage Supabase managed services instead of custom backend
2. **Database-Driven API**: Use PostgREST auto-generated API from schema
3. **Row-Level Security (RLS)**: Database-level authorization policies
4. **Edge Functions for Custom Logic**: Deno-based serverless for business logic
5. **Real-time by Default**: Use Supabase real-time subscriptions
6. **Fail-Safe Design**: Graceful degradation when external services unavailable
7. **Security by Default**: RLS, JWT authentication, HTTPS everywhere
8. **Type-Safe**: TypeScript end-to-end with auto-generated types
9. **Data Integrity**: Database constraints, triggers, and validations
10. **Observability**: Supabase logs + Sentry for comprehensive monitoring

---

## 3. High-Level Architecture

### 3.1 Supabase-Based Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  React Frontend (TypeScript + Vite)                          │   │
│  │  - Pages, Components, State Management (Zustand)             │   │
│  │  │  - Routing (React Router), Forms (React Hook Form)          │   │
│  │  - UI Components (Tailwind + shadcn/ui)                     │   │
│  │  - Supabase JS Client                                        │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑ (HTTPS)
┌─────────────────────────────────────────────────────────────────────┐
│                    Supabase Platform (BaaS)                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Supabase Services                                            │   │
│  │  ┌────────────────────┐  ┌────────────────────┐              │   │
│  │  │  PostgREST API     │  │  Supabase Auth     │              │   │
│  │  │  (Auto-generated)  │  │  (JWT-based)       │              │   │
│  │  └────────────────────┘  └────────────────────┘              │   │
│  │  ┌────────────────────┐  ┌────────────────────┐              │   │
│  │  │  Realtime          │  │  Supabase Storage  │              │   │
│  │  │  (WebSockets)      │  │  (File uploads)    │              │   │
│  │  └────────────────────┘  └────────────────────┘              │   │
│  │  ┌──────────────────────────────────────────────┐            │   │
│  │  │  Edge Functions (Deno)                       │            │   │
│  │  │  - Shopify integration                       │            │   │
│  │  │  - Email sending                             │            │   │
│  │  │  - Analytics calculations                    │            │   │
│  │  │  - Webhook processing                        │            │   │
│  │  └──────────────────────────────────────────────┘            │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                               ↓ ↑
┌─────────────────────────────────────────────────────────────────────┐
│                     PostgreSQL Database                             │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Managed PostgreSQL 15+                                       │   │
│  │  - Tables (customers, orders, activities, etc.)              │   │
│  │  - Row Level Security (RLS) Policies                         │   │
│  │  - Database Functions & Triggers                             │   │
│  │  - Views (for analytics)                                     │   │
│  │  - Indexes (optimized for queries)                           │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Communication Patterns

- **Frontend ↔ Supabase API**: REST API over HTTPS with JWT tokens
- **Frontend ↔ Supabase Realtime**: WebSocket for real-time updates
- **Frontend ↔ Supabase Storage**: HTTPS for file uploads/downloads
- **Edge Functions ↔ Database**: Direct PostgreSQL connections
- **Edge Functions ↔ External APIs**: HTTPS requests (Shopify, SendGrid)
- **Database Triggers → Edge Functions**: Event-driven architecture
- **Scheduled Jobs**: Supabase cron triggers calling Edge Functions

---

## 4. Component Architecture

### 4.1 Frontend Architecture

#### 4.1.1 Directory Structure

```
frontend/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── ui/             # Base UI (shadcn/ui components)
│   │   ├── common/         # Common components (Header, Sidebar)
│   │   └── shared/         # Shared business components
│   ├── features/           # Feature-based organization
│   │   ├── customers/
│   │   │   ├── components/ # Customer-specific components
│   │   │   ├── hooks/      # useCustomers, useCustomer, etc.
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
│   │   ├── uiStore.ts
│   │   └── settingsStore.ts
│   ├── lib/                # Core libraries
│   │   └── supabase.ts     # Supabase client initialization
│   ├── hooks/              # Global custom hooks
│   │   ├── useSupabase.ts  # Supabase client hook
│   │   ├── useAuth.ts      # Authentication hook
│   │   ├── useRealtime.ts  # Realtime subscription hook
│   │   └── useQuery.ts     # Query abstraction
│   ├── utils/              # Utility functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── helpers.ts
│   ├── types/              # Global TypeScript types
│   │   └── database.ts     # Auto-generated from Supabase schema
│   ├── App.tsx
│   └── main.tsx
```

#### 4.1.2 Supabase Client Setup

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import { Database } from '@/types/database'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
})
```

#### 4.1.3 Custom Hooks Pattern

```typescript
// hooks/useCustomers.ts
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import type { Database } from '@/types/database'

type Customer = Database['public']['Tables']['customers']['Row']

export function useCustomers(filters?: { country?: string; status?: string }) {
  const [customers, setCustomers] = useState<Customer[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchCustomers() {
      try {
        let query = supabase
          .from('customers')
          .select('*')
          .order('created_at', { ascending: false })

        if (filters?.country) {
          query = query.eq('country_code', filters.country)
        }
        if (filters?.status) {
          query = query.eq('status', filters.status)
        }

        const { data, error } = await query

        if (error) throw error
        setCustomers(data || [])
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    }

    fetchCustomers()
  }, [filters])

  return { customers, loading, error }
}
```

#### 4.1.4 Real-time Subscriptions

```typescript
// hooks/useRealtimeCustomers.ts
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import type { RealtimePostgresChangesPayload } from '@supabase/supabase-js'

export function useRealtimeCustomers() {
  const [customers, setCustomers] = useState<Customer[]>([])

  useEffect(() => {
    // Initial fetch
    fetchCustomers()

    // Subscribe to realtime changes
    const channel = supabase
      .channel('customers-channel')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'customers',
        },
        (payload: RealtimePostgresChangesPayload<Customer>) => {
          if (payload.eventType === 'INSERT') {
            setCustomers((prev) => [payload.new, ...prev])
          } else if (payload.eventType === 'UPDATE') {
            setCustomers((prev) =>
              prev.map((c) => (c.id === payload.new.id ? payload.new : c))
            )
          } else if (payload.eventType === 'DELETE') {
            setCustomers((prev) => prev.filter((c) => c.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return { customers }
}
```

### 4.2 Edge Functions Architecture

#### 4.2.1 Edge Functions Structure

```
supabase/functions/
├── _shared/
│   ├── supabase.ts         # Supabase client for Edge Functions
│   ├── types.ts            # Shared TypeScript types
│   ├── shopify.ts          # Shopify API client
│   └── sendgrid.ts         # SendGrid API client
├── shopify-sync/
│   └── index.ts            # Sync customers and orders from Shopify
├── shopify-webhook/
│   └── index.ts            # Process Shopify webhooks
├── send-email/
│   └── index.ts            # Send emails via SendGrid
├── calculate-analytics/
│   └── index.ts            # Calculate analytics metrics
└── scheduled-sync/
    └── index.ts            # Daily/hourly scheduled sync
```

#### 4.2.2 Edge Function Example

```typescript
// supabase/functions/shopify-sync/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { shopifyClient } from '../_shared/shopify.ts'

serve(async (req) => {
  try {
    // Authenticate request
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // Verify user is authenticated
    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
      })
    }

    // Get integration details from database
    const { data: integration } = await supabase
      .from('integrations')
      .select('*')
      .eq('platform', 'shopify')
      .single()

    if (!integration) {
      return new Response(JSON.stringify({ error: 'Integration not found' }), {
        status: 404,
      })
    }

    // Fetch customers from Shopify
    const shopify = shopifyClient(integration.credentials)
    const customers = await shopify.getCustomers()

    // Upsert customers into database
    const { data, error } = await supabase
      .from('customers')
      .upsert(
        customers.map((c) => ({
          email: c.email,
          first_name: c.first_name,
          last_name: c.last_name,
          country_code: c.default_address?.country_code,
          external_id: c.id.toString(),
          external_platform: 'shopify',
        })),
        { onConflict: 'external_id,external_platform' }
      )

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        synced: customers.length,
      }),
      {
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    })
  }
})
```

#### 4.2.3 Scheduled Edge Functions

```typescript
// supabase/functions/scheduled-sync/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  // Verify this is a cron job (from Supabase)
  const authHeader = req.headers.get('Authorization')
  if (authHeader !== `Bearer ${Deno.env.get('CRON_SECRET')}`) {
    return new Response('Unauthorized', { status: 401 })
  }

  // Trigger sync for all active integrations
  const response = await fetch(
    `${Deno.env.get('SUPABASE_URL')}/functions/v1/shopify-sync`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
      },
    }
  )

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 5. Data Architecture

### 5.1 Database Schema

#### 5.1.1 Core Tables

```sql
-- Users (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'agent', 'readonly')),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    language TEXT NOT NULL DEFAULT 'en',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers
CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    company_name TEXT,
    country_code TEXT NOT NULL,
    region TEXT,
    city TEXT,
    postal_code TEXT,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    language TEXT NOT NULL DEFAULT 'en',
    currency TEXT NOT NULL DEFAULT 'USD',
    status TEXT NOT NULL CHECK (status IN ('active', 'inactive', 'vip', 'blocked')),
    custom_fields JSONB,
    lifetime_value NUMERIC(15, 2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    average_order_value NUMERIC(15, 2) DEFAULT 0.00,
    first_order_date TIMESTAMP WITH TIME ZONE,
    last_order_date TIMESTAMP WITH TIME ZONE,
    external_id TEXT,
    external_platform TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(external_id, external_platform)
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_country ON customers(country_code);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_created_at ON customers(created_at);
CREATE INDEX idx_customers_custom_fields ON customers USING GIN (custom_fields);

-- Orders
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_number TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    total_amount NUMERIC(15, 2) NOT NULL,
    currency TEXT NOT NULL,
    total_amount_usd NUMERIC(15, 2) NOT NULL,
    tax_amount NUMERIC(15, 2) DEFAULT 0.00,
    shipping_amount NUMERIC(15, 2) DEFAULT 0.00,
    shipping_country TEXT,
    shipping_address JSONB,
    tracking_number TEXT,
    carrier TEXT,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    source TEXT,
    notes TEXT,
    external_id TEXT,
    external_platform TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(external_id, external_platform)
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Activities
CREATE TABLE public.activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('email', 'call', 'meeting', 'note', 'task')),
    subject TEXT,
    description TEXT,
    direction TEXT CHECK (direction IN ('inbound', 'outbound')),
    status TEXT CHECK (status IN ('pending', 'completed', 'cancelled')),
    due_date TIMESTAMP WITH TIME ZONE,
    email_metadata JSONB,
    attachments TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_activities_customer_id ON activities(customer_id);
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_created_at ON activities(created_at);

-- Tags
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customer Tags (many-to-many)
CREATE TABLE public.customer_tags (
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (customer_id, tag_id)
);

-- Integrations
CREATE TABLE public.integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform TEXT NOT NULL CHECK (platform IN ('shopify', 'woocommerce')),
    shop_name TEXT NOT NULL,
    credentials JSONB NOT NULL, -- Encrypted
    status TEXT NOT NULL CHECK (status IN ('active', 'inactive', 'error')),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email Templates
CREATE TABLE public.email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'en',
    subject TEXT NOT NULL,
    body TEXT NOT NULL,
    variables TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 5.1.2 Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view all users"
    ON users FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage users"
    ON users FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Customers table policies
CREATE POLICY "Admins and managers can view all customers"
    ON customers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager', 'readonly')
        )
    );

CREATE POLICY "Agents can only view assigned customers"
    ON customers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'agent'
        )
        -- TODO: Add assignment logic
    );

CREATE POLICY "Admins and managers can modify customers"
    ON customers FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
        )
    );

-- Orders table policies (inherit from customers)
CREATE POLICY "Users can view orders for accessible customers"
    ON orders FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM customers
            WHERE customers.id = orders.customer_id
        )
    );

-- Activities table policies
CREATE POLICY "Users can view activities for accessible customers"
    ON activities FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM customers
            WHERE customers.id = activities.customer_id
        )
    );

CREATE POLICY "Users can create activities"
    ON activities FOR INSERT
    WITH CHECK (auth.uid() = user_id);
```

#### 5.1.3 Database Functions

```sql
-- Function to update customer metrics after order insert/update
CREATE OR REPLACE FUNCTION update_customer_metrics()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE customers SET
        total_orders = (SELECT COUNT(*) FROM orders WHERE customer_id = NEW.customer_id),
        lifetime_value = (SELECT COALESCE(SUM(total_amount_usd), 0) FROM orders WHERE customer_id = NEW.customer_id),
        average_order_value = (SELECT COALESCE(AVG(total_amount_usd), 0) FROM orders WHERE customer_id = NEW.customer_id),
        last_order_date = (SELECT MAX(created_at) FROM orders WHERE customer_id = NEW.customer_id),
        first_order_date = (SELECT MIN(created_at) FROM orders WHERE customer_id = NEW.customer_id)
    WHERE id = NEW.customer_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customer_metrics_trigger
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_customer_metrics();
```

#### 5.1.4 Database Views for Analytics

```sql
-- Customer growth by country
CREATE VIEW customer_growth_by_country AS
SELECT
    country_code,
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS new_customers,
    SUM(COUNT(*)) OVER (PARTITION BY country_code ORDER BY DATE_TRUNC('month', created_at)) AS cumulative_customers
FROM customers
GROUP BY country_code, DATE_TRUNC('month', created_at);

-- Revenue by country
CREATE VIEW revenue_by_country AS
SELECT
    customers.country_code,
    DATE_TRUNC('month', orders.created_at) AS month,
    SUM(orders.total_amount_usd) AS revenue,
    COUNT(orders.id) AS order_count
FROM orders
JOIN customers ON orders.customer_id = customers.id
GROUP BY customers.country_code, DATE_TRUNC('month', orders.created_at);

-- Top customers by LTV
CREATE VIEW top_customers AS
SELECT
    id,
    email,
    first_name,
    last_name,
    country_code,
    lifetime_value,
    total_orders,
    average_order_value
FROM customers
WHERE lifetime_value > 0
ORDER BY lifetime_value DESC
LIMIT 100;
```

---

## 6. API Architecture

### 6.1 PostgREST Auto-Generated API

Supabase automatically generates a REST API from the database schema using PostgREST.

#### 6.1.1 Available Endpoints

**Base URL:** `https://your-project.supabase.co/rest/v1/`

All tables are automatically exposed as REST endpoints:

```
GET    /customers              - List customers
POST   /customers              - Create customer
GET    /customers?id=eq.{id}   - Get customer by ID
PATCH  /customers?id=eq.{id}   - Update customer
DELETE /customers?id=eq.{id}   - Delete customer

GET    /orders                 - List orders
POST   /orders                 - Create order
GET    /orders?id=eq.{id}      - Get order

GET    /activities             - List activities
POST   /activities             - Create activity
```

#### 6.1.2 Query Features

**Filtering:**
```
GET /customers?country_code=eq.US
GET /customers?status=eq.active
GET /customers?lifetime_value=gte.1000
```

**Sorting:**
```
GET /customers?order=created_at.desc
GET /customers?order=lifetime_value.desc
```

**Pagination:**
```
GET /customers?limit=25&offset=0
```

**Relationships (JOINs):**
```
GET /customers?select=*,orders(*)
GET /orders?select=*,customer:customers(*)
```

**Full-text Search:**
```
GET /customers?or=(first_name.ilike.*john*,last_name.ilike.*john*)
```

#### 6.1.3 Using Supabase JS Client

```typescript
// List customers with filters
const { data, error } = await supabase
  .from('customers')
  .select('*')
  .eq('country_code', 'US')
  .order('created_at', { ascending: false })
  .range(0, 24)

// Get customer with orders
const { data, error } = await supabase
  .from('customers')
  .select(`
    *,
    orders (*)
  `)
  .eq('id', customerId)
  .single()

// Create customer
const { data, error } = await supabase
  .from('customers')
  .insert({
    email: 'customer@example.com',
    first_name: 'John',
    last_name: 'Doe',
    country_code: 'US',
  })
  .select()
  .single()

// Update customer
const { data, error } = await supabase
  .from('customers')
  .update({ status: 'vip' })
  .eq('id', customerId)

// Delete customer
const { error } = await supabase
  .from('customers')
  .delete()
  .eq('id', customerId)
```

### 6.2 Edge Functions as Custom Endpoints

For complex business logic not suited for direct database queries:

```
POST /functions/v1/shopify-sync
POST /functions/v1/send-email
POST /functions/v1/calculate-analytics
```

---

## 7. Integration Architecture

### 7.1 Shopify Integration via Edge Functions

```typescript
// supabase/functions/shopify-webhook/index.ts
serve(async (req) => {
  // Verify Shopify webhook signature
  const hmac = req.headers.get('X-Shopify-Hmac-Sha256')
  const shop = req.headers.get('X-Shopify-Shop-Domain')
  const topic = req.headers.get('X-Shopify-Topic')

  const body = await req.text()
  const verified = await verifyShopifyWebhook(hmac, body)

  if (!verified) {
    return new Response('Invalid signature', { status: 401 })
  }

  const data = JSON.parse(body)

  // Create Supabase client with service role key (bypass RLS)
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  )

  // Handle different webhook topics
  switch (topic) {
    case 'orders/create':
    case 'orders/updated':
      await supabase.from('orders').upsert({
        customer_id: data.customer.id,
        order_number: data.name,
        total_amount: parseFloat(data.total_price),
        currency: data.currency,
        external_id: data.id.toString(),
        external_platform: 'shopify',
      })
      break

    case 'customers/create':
    case 'customers/update':
      await supabase.from('customers').upsert({
        email: data.email,
        first_name: data.first_name,
        last_name: data.last_name,
        external_id: data.id.toString(),
        external_platform: 'shopify',
      })
      break
  }

  return new Response('OK', { status: 200 })
})
```

### 7.2 Email Integration via Edge Functions

```typescript
// supabase/functions/send-email/index.ts
import { sendGridClient } from '../_shared/sendgrid.ts'

serve(async (req) => {
  const { customer_id, template_id, variables } = await req.json()

  // Authenticate
  const supabase = createClient(/* ... */)
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // Get customer
  const { data: customer } = await supabase
    .from('customers')
    .select('*')
    .eq('id', customer_id)
    .single()

  // Get template
  const { data: template } = await supabase
    .from('email_templates')
    .select('*')
    .eq('id', template_id)
    .single()

  // Render template
  const subject = renderTemplate(template.subject, { ...variables, customer })
  const body = renderTemplate(template.body, { ...variables, customer })

  // Send email
  await sendGridClient.send({
    to: customer.email,
    from: 'noreply@crm.example.com',
    subject,
    html: body,
  })

  // Log activity
  await supabase.from('activities').insert({
    customer_id,
    user_id: user.id,
    type: 'email',
    subject,
    direction: 'outbound',
  })

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 8. Security Architecture

### 8.1 Authentication

**Supabase Auth (JWT-based)**

```typescript
// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password',
})

// Signup
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password',
})

// Get current user
const { data: { user } } = await supabase.auth.getUser()

// Logout
await supabase.auth.signOut()

// Password reset
await supabase.auth.resetPasswordForEmail('user@example.com')
```

### 8.2 Authorization (Row-Level Security)

Authorization is enforced at the database level using RLS policies.

**Benefits:**
- Cannot be bypassed (enforced by PostgreSQL)
- Works with auto-generated API
- Works with Edge Functions
- Works with real-time subscriptions

**Example Policy:**
```sql
-- Agents can only view assigned customers
CREATE POLICY "agents_view_assigned"
    ON customers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM customer_assignments
            WHERE customer_id = customers.id
            AND user_id = auth.uid()
        )
        OR
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
            AND role IN ('admin', 'manager')
        )
    );
```

### 8.3 Data Encryption

- **In Transit**: HTTPS/TLS for all connections
- **At Rest**: Supabase encrypts all data at rest
- **Credentials**: Store sensitive integration credentials encrypted in JSONB

### 8.4 GDPR Compliance

```sql
-- Data export function
CREATE OR REPLACE FUNCTION export_customer_data(p_customer_id UUID)
RETURNS JSONB AS $$
BEGIN
    RETURN jsonb_build_object(
        'customer', (SELECT row_to_json(customers.*) FROM customers WHERE id = p_customer_id),
        'orders', (SELECT json_agg(orders.*) FROM orders WHERE customer_id = p_customer_id),
        'activities', (SELECT json_agg(activities.*) FROM activities WHERE customer_id = p_customer_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Data deletion function (right to be forgotten)
CREATE OR REPLACE FUNCTION anonymize_customer(p_customer_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE customers SET
        email = 'deleted_' || id || '@example.com',
        first_name = 'Deleted',
        last_name = 'User',
        phone = NULL,
        custom_fields = NULL,
        status = 'inactive'
    WHERE id = p_customer_id;

    DELETE FROM activities WHERE customer_id = p_customer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 9. Deployment Architecture

### 9.1 Production Architecture

```
┌─────────────────────────────────────────────┐
│         CloudFlare CDN                      │
│    - Frontend static files                  │
│    - DDoS protection                        │
└───────────────┬─────────────────────────────┘
                │
                ↓
┌─────────────────────────────────────────────┐
│      Vercel / Netlify / AWS S3              │
│    - React frontend hosting                 │
│    - Automatic deployments                  │
└───────────────┬─────────────────────────────┘
                │
                ↓ (HTTPS)
┌─────────────────────────────────────────────┐
│          Supabase Platform                  │
│  ┌────────────────────────────────────────┐ │
│  │  API Gateway                           │ │
│  │  - Rate limiting                       │ │
│  │  - Authentication                      │ │
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │  PostgreSQL (Primary)                  │ │
│  │  + Read Replicas                       │ │
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │  Edge Functions (Deno)                 │ │
│  │  - Distributed globally                │ │
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │  Supabase Storage                      │ │
│  │  - S3-compatible                       │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
                │
                ↓
┌─────────────────────────────────────────────┐
│       External Services                     │
│  - Sentry (error tracking)                  │
│  - SendGrid (email)                         │
│  - Shopify API                              │
└─────────────────────────────────────────────┘
```

### 9.2 CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build frontend
        run: |
          cd frontend
          npm install
          npm run build
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}

  deploy-edge-functions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy Edge Functions
        run: |
          npx supabase functions deploy --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

---

## 10. Scalability Architecture

### 10.1 Horizontal Scaling

**Automatic with Supabase:**
- Database connection pooling (PgBouncer)
- Read replicas for read-heavy workloads
- Edge Functions distributed globally
- CDN for frontend assets

### 10.2 Performance Optimization

**Database:**
- Proper indexes on all query columns
- Database views for complex analytics
- Connection pooling
- Query result caching

**Frontend:**
- Code splitting
- Lazy loading
- Image optimization
- Service worker caching (PWA)

---

## 11. Technology Stack Rationale

### 11.1 Why Supabase?

**Pros:**
✅ Instant backend without writing backend code
✅ Auto-generated REST API from schema
✅ Built-in authentication (JWT)
✅ Real-time subscriptions out of the box
✅ Row-level security for fine-grained permissions
✅ Managed PostgreSQL with backups
✅ Generous free tier
✅ TypeScript SDK
✅ Faster time to market

**Cons:**
⚠️ Less control over backend logic (mitigated with Edge Functions)
⚠️ Vendor lock-in (mitigated by using standard PostgreSQL)
⚠️ Learning curve for RLS policies

### 11.2 Why Edge Functions (Deno)?

**Pros:**
✅ TypeScript-first
✅ Serverless (no servers to manage)
✅ Fast cold starts
✅ Built-in TypeScript support
✅ Secure by default

**Cons:**
⚠️ Limited to Deno runtime
⚠️ Cold start latency (acceptable for most use cases)

---

## 12. Design Patterns

### 12.1 Frontend Patterns

**1. Custom Hooks for Data Fetching:**
```typescript
function useCustomers(filters) {
  const [data, setData] = useState([])
  useEffect(() => {
    supabase.from('customers').select('*').then(setData)
  }, [filters])
  return data
}
```

**2. Real-time Subscriptions:**
```typescript
useEffect(() => {
  const channel = supabase
    .channel('table-changes')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'customers' }, handleChange)
    .subscribe()
  return () => supabase.removeChannel(channel)
}, [])
```

### 12.2 Database Patterns

**1. Triggers for Calculated Fields:**
```sql
CREATE TRIGGER update_metrics
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_customer_metrics();
```

**2. Views for Complex Queries:**
```sql
CREATE VIEW customer_analytics AS
SELECT ...complex query...
```

---

## 13. Development Architecture

### 13.1 Local Development

```bash
# Start Supabase locally
supabase start

# Run migrations
supabase db push

# Run Edge Functions locally
supabase functions serve

# Start frontend
cd frontend && npm run dev
```

---

## 14. Monitoring and Observability

**Supabase Dashboard:**
- Database health
- API request metrics
- Edge Function logs
- Real-time connections

**Sentry:**
- Frontend error tracking
- Edge Function error tracking

**Supabase Logs:**
- Database query logs
- Edge Function execution logs

---

## 15. Disaster Recovery and Backup

**Automated Backups:**
- Daily automated backups (Supabase Pro plan)
- Point-in-time recovery
- Cross-region replication

**Recovery:**
- RTO: < 1 hour (restore from backup)
- RPO: < 15 minutes (continuous backup)

---

## 16. Architecture Decision Records

### ADR-001: Use Supabase Instead of Django

**Status:** Accepted

**Context:** Need to choose backend architecture

**Decision:** Use Supabase (BaaS) instead of Django custom backend

**Rationale:**
- Faster time to market (no backend code to write)
- Auto-generated REST API
- Built-in authentication, real-time, storage
- Managed PostgreSQL with backups
- Cost-effective
- Team can focus on frontend and business logic

**Consequences:**
- Less control over backend (mitigated with Edge Functions)
- Vendor lock-in (mitigated by using standard PostgreSQL)
- Need to learn RLS and Edge Functions

---

### ADR-002: Use Edge Functions for Business Logic

**Status:** Accepted

**Context:** Need to handle complex business logic (Shopify sync, email sending)

**Decision:** Use Supabase Edge Functions (Deno)

**Rationale:**
- Serverless (no infrastructure management)
- TypeScript-first
- Integrates seamlessly with Supabase
- Fast execution
- Automatic scaling

**Consequences:**
- Limited to Deno runtime
- Cold start latency (acceptable)
- Need to learn Deno

---

### ADR-003: Use Row-Level Security for Authorization

**Status:** Accepted

**Context:** Need fine-grained access control

**Decision:** Use PostgreSQL Row-Level Security (RLS)

**Rationale:**
- Database-level security (cannot be bypassed)
- Works with auto-generated API
- Works with Edge Functions
- Works with real-time subscriptions
- More secure than application-level checks

**Consequences:**
- More complex than Django permissions
- Requires understanding of PostgreSQL policies
- Testing RLS policies requires database access

---

## Document Control

**Version**: 2.0
**Date**: 2026-01-21
**Author**: Technical Architect
**Status**: Final

### Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-19 | Technical Architect | Initial architecture with Django backend |
| 2.0 | 2026-01-21 | Technical Architect | **Major Update**: Replaced Django with Supabase BaaS. Complete rewrite for Supabase architecture including PostgREST API, Edge Functions, RLS, and updated all sections accordingly. |

---

## References

- Supabase Documentation: https://supabase.com/docs
- PostgREST API: https://postgrest.org/
- Deno Documentation: https://deno.land/manual
- React Documentation: https://react.dev/
- PostgreSQL Row-Level Security: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
