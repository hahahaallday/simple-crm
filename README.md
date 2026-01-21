# Simple CRM - Cross-Border Ecommerce Customer Relationship Management

A comprehensive, modern CRM system designed specifically for cross-border ecommerce businesses. Built with Django REST Framework and React TypeScript, this system helps manage customer relationships across multiple countries, currencies, and languages.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![Django](https://img.shields.io/badge/Django-5.0-green.svg)](https://www.djangoproject.com/)
[![React](https://img.shields.io/badge/React-18-blue.svg)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)

---

## 📋 Table of Contents

- [Features](#-features)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Development](#-development)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Documentation](#-documentation)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### Core Features

- **Customer Management**
  - 360° customer profiles with comprehensive data
  - Multi-currency order tracking with USD normalization
  - Customer segmentation and tagging
  - Custom fields support
  - Import/export capabilities (CSV)

- **Order Management**
  - Real-time order tracking across borders
  - Multi-currency support (ISO 4217)
  - Shipping and fulfillment tracking
  - Order timeline and status updates

- **Activity Tracking**
  - Complete interaction timeline (emails, calls, meetings, notes)
  - Task management with reminders
  - File attachments support
  - Automated activity capture from integrations

- **Communication Hub**
  - Email templates with multi-language support
  - Variable substitution (customer name, order number, etc.)
  - Email tracking (opens, clicks)
  - Integration with SendGrid/AWS SES

- **Analytics & Reporting**
  - Customer growth trends by country
  - Revenue analytics with currency normalization
  - Top customers by LTV and order count
  - Cohort analysis and churn prediction
  - Geographic distribution reports

- **Integrations**
  - **Shopify**: OAuth authentication, real-time webhook sync
  - **WooCommerce**: REST API integration (planned)
  - Email services (SendGrid, AWS SES)
  - Extensible integration framework

- **Team Management**
  - Role-based access control (Admin, Manager, Agent, Read-only)
  - User activity tracking
  - Team performance metrics

### Cross-Border Features

- **Multi-Currency Support**: Track orders in original currency with automatic USD normalization
- **Multi-Language UI**: Support for English, Spanish, French, German, Chinese
- **Timezone Awareness**: Store and display times in user's timezone
- **International Address Formats**: Flexible address storage (JSON)
- **Geographic Analytics**: Revenue and customer distribution by country/region

---

## 🛠 Technology Stack

### Backend (Supabase - BaaS)

- **Platform**: Supabase (Backend-as-a-Service)
- **Database**: PostgreSQL 15+ (managed by Supabase)
- **API**: Auto-generated REST API (PostgREST)
- **Authentication**: Supabase Auth (JWT-based)
- **Real-time**: Built-in WebSocket subscriptions
- **Storage**: Supabase Storage (file uploads)
- **Edge Functions**: Deno-based serverless functions
- **Row-Level Security (RLS)**: Database-level authorization

**Why Supabase:**
- ✅ Instant REST API from database schema
- ✅ No backend code to write
- ✅ Built-in auth, real-time, and storage
- ✅ Generous free tier, scales automatically
- ✅ TypeScript SDK with auto-generated types

**Edge Functions (Deno/TypeScript):**
- Shopify integration and webhook processing
- Email sending via SendGrid
- Complex analytics calculations
- Scheduled sync tasks

### Frontend

- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite (fast HMR)
- **State Management**: Zustand (lightweight)
- **UI Components**: Tailwind CSS + shadcn/ui
- **HTTP Client**: Supabase JS Client
- **Routing**: React Router v6
- **Forms**: React Hook Form + Zod validation
- **Charts**: Recharts
- **Date Handling**: date-fns with timezone support

**Key NPM Packages:**
```json
{
  "react": "^18.2.0",
  "react-router-dom": "^6.21.1",
  "@supabase/supabase-js": "^2.39.0",
  "zustand": "^4.4.7",
  "tailwindcss": "^3.4.1",
  "recharts": "^2.10.3"
}
```

### DevOps

- **Frontend Hosting**: Vercel / Netlify
- **Backend**: Supabase (managed)
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry (error tracking) + Supabase logs
- **Testing**: Vitest + React Testing Library (frontend), Deno test (Edge Functions)

---

## 🏗 Architecture

This CRM uses **Supabase** as a Backend-as-a-Service platform:

```
┌─────────────────────────────────────────┐
│     Presentation Layer (React)          │
│  - UI Components, State Management      │
│  - Supabase JS Client                   │
└─────────────────────────────────────────┘
                  ↓ ↑ (HTTPS)
┌─────────────────────────────────────────┐
│      Supabase Platform (BaaS)           │
│  - PostgREST API (auto-generated)       │
│  - Supabase Auth (JWT)                  │
│  - Realtime (WebSockets)                │
│  - Supabase Storage                     │
│  - Edge Functions (Deno)                │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│   PostgreSQL Database                   │
│  - Tables with RLS policies             │
│  - Database functions & triggers        │
│  - Views for analytics                  │
└─────────────────────────────────────────┘
```

**Key Architectural Decisions:**

- **BaaS-First**: Leverage Supabase managed services instead of custom backend
- **Database-Driven API**: Auto-generated REST API from PostgreSQL schema
- **Row-Level Security (RLS)**: Database-level authorization (cannot be bypassed)
- **Edge Functions**: Deno-based serverless for custom business logic
- **Real-time by Default**: Built-in WebSocket subscriptions
- **Type-Safe**: TypeScript end-to-end with auto-generated database types

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 📁 Project Structure

```
simple-crm/
├── supabase/                   # Supabase backend configuration
│   ├── config.toml            # Supabase project config
│   ├── migrations/            # Database migrations (SQL)
│   │   ├── 20240101_create_users.sql
│   │   ├── 20240102_create_customers.sql
│   │   ├── 20240103_create_orders.sql
│   │   ├── 20240104_create_activities.sql
│   │   └── 20240105_rls_policies.sql
│   ├── functions/             # Edge Functions (Deno/TypeScript)
│   │   ├── shopify-sync/      # Sync Shopify data
│   │   ├── shopify-webhook/   # Process Shopify webhooks
│   │   ├── send-email/        # Send emails via SendGrid
│   │   ├── calculate-analytics/ # Generate analytics
│   │   └── _shared/           # Shared utilities
│   └── seed.sql               # Seed data for development
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/        # Reusable UI components
│   │   ├── features/          # Feature-specific modules
│   │   │   ├── customers/     # Customer management
│   │   │   ├── orders/        # Order management
│   │   │   ├── activities/    # Activity tracking
│   │   │   ├── analytics/     # Analytics & reports
│   │   │   └── settings/      # Settings & integrations
│   │   ├── hooks/             # Custom React hooks
│   │   │   ├── useSupabase.ts # Supabase client hook
│   │   │   ├── useAuth.ts     # Authentication hook
│   │   │   ├── useRealtime.ts # Real-time subscriptions
│   │   │   └── useCustomers.ts # Customer data hook
│   │   ├── layouts/           # Page layouts
│   │   ├── pages/             # Route pages
│   │   ├── store/             # Zustand stores
│   │   ├── lib/               # Library setup
│   │   │   └── supabase.ts    # Supabase client config
│   │   ├── types/             # TypeScript types
│   │   │   └── database.ts    # Auto-generated from Supabase
│   │   ├── utils/             # Utilities
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── tailwind.config.js
│
├── .env.example                # Environment variables template
├── .gitignore
├── README.md                   # This file
├── ARCHITECTURE.md             # Architecture documentation
├── SYSTEM_SPEC.md              # System specification
└── LICENSE
```

---

## 🚀 Getting Started

### Prerequisites

- **Node.js 18+** and **npm**
- **Supabase CLI** - [Installation guide](https://supabase.com/docs/guides/cli)
- **Deno** (for Edge Functions development) - [Installation guide](https://deno.land/manual/getting_started/installation)
- **Supabase Account** - [Sign up for free](https://supabase.com)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/hahahaallday/simple-crm.git
   cd simple-crm
   ```

2. **Set up Supabase project**

   Create a new Supabase project at [supabase.com](https://supabase.com), then:

   ```bash
   # Log in to Supabase CLI
   supabase login

   # Link to your Supabase project
   supabase link --project-ref your-project-ref
   ```

3. **Run database migrations**
   ```bash
   supabase db push
   ```

4. **Set up environment variables**
   ```bash
   cd frontend
   cp .env.example .env
   ```

   Edit `.env` with your Supabase credentials:
   ```env
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key
   ```

5. **Install frontend dependencies**
   ```bash
   npm install
   ```

6. **Start development server**
   ```bash
   npm run dev
   ```

7. **Deploy Edge Functions** (optional for local dev)
   ```bash
   # Deploy all Edge Functions to Supabase
   supabase functions deploy shopify-sync
   supabase functions deploy shopify-webhook
   supabase functions deploy send-email
   supabase functions deploy calculate-analytics
   ```

8. **Access the application**
   - Frontend: http://localhost:5173
   - Supabase Studio (local): http://localhost:54323
   - Supabase API: Provided by Supabase (auto-generated REST API)

### Local Supabase Development (Optional)

For completely local development without cloud connection:

1. **Start local Supabase**
   ```bash
   supabase start
   ```

   This starts:
   - PostgreSQL database
   - PostgREST API server
   - Supabase Studio (web UI)
   - Auth server
   - Storage server
   - Realtime server

2. **Get local credentials**
   ```bash
   supabase status
   ```

   Use the local credentials in your `.env` file.

3. **Stop local Supabase**
   ```bash
   supabase stop
   ```

---

## 💻 Development

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Database: Create migration files in `supabase/migrations/`
   - Edge Functions: Modify or add functions in `supabase/functions/`
   - Frontend: Modify React components in `frontend/src/`

3. **Apply database changes**
   ```bash
   # Create a new migration
   supabase migration new your_migration_name

   # Edit the migration file in supabase/migrations/
   # Then push to database
   supabase db push
   ```

4. **Test Edge Functions locally**
   ```bash
   # Serve a specific function locally
   supabase functions serve shopify-sync --env-file .env
   ```

5. **Run tests**
   ```bash
   # Frontend tests
   cd frontend
   npm test

   # Edge Function tests (Deno)
   cd supabase/functions/shopify-sync
   deno test
   ```

6. **Run linters**
   ```bash
   # Frontend (TypeScript)
   npm run lint
   npm run format
   ```

7. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

8. **Push and create pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style

**Edge Functions (Deno/TypeScript):**
- Follow Deno style guide
- Use `deno fmt` for formatting
- Use TypeScript strict mode
- Prefer async/await over callbacks

**Frontend (TypeScript):**
- Follow Airbnb style guide
- Use ESLint + Prettier
- Use TypeScript strict mode
- Prefer functional components with hooks

### Database Migrations

**Create a new migration:**
```bash
supabase migration new add_customer_tags
```

This creates a new SQL file in `supabase/migrations/`.

**Example migration:**
```sql
-- supabase/migrations/20240101_add_customer_tags.sql
CREATE TABLE customer_tags (
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (customer_id, tag_id)
);

-- Add RLS policy
ALTER TABLE customer_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view customer tags"
    ON customer_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid()
        )
    );
```

**Apply migrations:**
```bash
supabase db push
```

**Rollback migration:**
```bash
supabase db reset
```

### Working with Supabase

**Generate TypeScript types from database:**
```bash
supabase gen types typescript --local > frontend/src/types/database.ts
```

**Access Supabase Studio (local):**
```bash
supabase start
# Then open http://localhost:54323
```

**View database logs:**
```bash
supabase logs db
```

### Edge Functions Development

**Create a new Edge Function:**
```bash
supabase functions new my-function
```

**Example Edge Function:**
```typescript
// supabase/functions/send-email/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { to, subject, body } = await req.json()

    // Your email sending logic here

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

**Deploy Edge Function:**
```bash
supabase functions deploy send-email
```

**Invoke Edge Function:**
```typescript
// From frontend
const { data, error } = await supabase.functions.invoke('send-email', {
  body: { to: 'user@example.com', subject: 'Hello', body: 'Message' }
})
```

---

## 🧪 Testing

### Edge Functions Testing

**Run tests for a specific function:**
```bash
cd supabase/functions/shopify-sync
deno test
```

**Run with coverage:**
```bash
deno test --coverage=coverage
deno coverage coverage
```

**Example test file:**
```typescript
// supabase/functions/shopify-sync/index.test.ts
import { assertEquals } from 'https://deno.land/std@0.168.0/testing/asserts.ts'

Deno.test('should sync customers from Shopify', async () => {
  // Your test logic here
  assertEquals(1 + 1, 2)
})
```

### Frontend Testing

**Run all tests:**
```bash
cd frontend
npm test
```

**Run in watch mode:**
```bash
npm test -- --watch
```

**Run with coverage:**
```bash
npm test -- --coverage
```

**Example component test:**
```typescript
// frontend/src/components/CustomerCard.test.tsx
import { render, screen } from '@testing-library/react'
import { CustomerCard } from './CustomerCard'

test('renders customer name', () => {
  render(<CustomerCard customer={{ name: 'John Doe', email: 'john@example.com' }} />)
  expect(screen.getByText('John Doe')).toBeInTheDocument()
})
```

### Database Testing

Test database functions and triggers:

```sql
-- Test in Supabase Studio or via SQL
BEGIN;
  -- Insert test data
  INSERT INTO customers (email, first_name) VALUES ('test@example.com', 'Test');

  -- Assert expected result
  SELECT * FROM customers WHERE email = 'test@example.com';

ROLLBACK;
```

### Testing Strategy

- **Unit Tests**: Test individual functions, components, Edge Functions
- **Integration Tests**: Test database queries, RLS policies, API interactions
- **E2E Tests**: Test complete user flows (planned with Playwright)
- **Target Coverage**: >80%

---

## 🚢 Deployment

### Supabase Backend Deployment

Supabase is already deployed and managed as a Backend-as-a-Service. No backend deployment needed!

**Deploy database migrations:**
```bash
# Link to your production Supabase project
supabase link --project-ref your-production-project-ref

# Push migrations to production
supabase db push
```

**Deploy Edge Functions:**
```bash
# Deploy all functions
supabase functions deploy shopify-sync
supabase functions deploy shopify-webhook
supabase functions deploy send-email
supabase functions deploy calculate-analytics

# Or deploy all at once
supabase functions deploy --no-verify-jwt
```

**Set Edge Function secrets:**
```bash
# Set environment variables for Edge Functions
supabase secrets set SENDGRID_API_KEY=your-key
supabase secrets set SHOPIFY_API_KEY=your-key
supabase secrets set SHOPIFY_API_SECRET=your-secret
```

### Frontend Deployment

**Deploy to Vercel (Recommended):**

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   ```bash
   cd frontend
   vercel --prod
   ```

3. **Set environment variables in Vercel dashboard:**
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

**Alternative: Deploy to Netlify:**

1. **Install Netlify CLI**
   ```bash
   npm i -g netlify-cli
   ```

2. **Build and deploy**
   ```bash
   cd frontend
   npm run build
   netlify deploy --prod --dir=dist
   ```

3. **Set environment variables in Netlify dashboard:**
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

### Environment Variables

**Frontend (.env.production):**
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

**Edge Function Secrets (via Supabase CLI):**
```bash
supabase secrets set SENDGRID_API_KEY=your-sendgrid-key
supabase secrets set SHOPIFY_API_KEY=your-shopify-key
supabase secrets set SHOPIFY_API_SECRET=your-shopify-secret
```

### CI/CD Pipeline

**GitHub Actions example:**

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Supabase CLI
        run: npm install -g supabase

      - name: Deploy migrations
        run: |
          supabase link --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
          supabase db push
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Deploy Edge Functions
        run: supabase functions deploy
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Deploy Frontend to Vercel
        run: |
          cd frontend
          npm install
          vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
```

### Production Checklist

- [ ] Supabase project created
- [ ] Database migrations applied
- [ ] Row-Level Security (RLS) policies enabled on all tables
- [ ] Edge Functions deployed
- [ ] Edge Function secrets configured
- [ ] Frontend deployed to Vercel/Netlify
- [ ] Environment variables set
- [ ] Custom domain configured (optional)
- [ ] SSL certificate active (automatic with Vercel/Netlify)
- [ ] Monitoring set up (Supabase Dashboard)
- [ ] Backups enabled (automatic with Supabase)

---

## 📚 Documentation

Comprehensive documentation is available in the following files:

- **[README.md](README.md)** - This file (project overview, setup, development)
- **[SYSTEM_SPEC.md](SYSTEM_SPEC.md)** - Complete system specification
  - Business requirements
  - Feature specifications
  - Data models
  - Implementation phases (24-week roadmap)
  - Success metrics

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture
  - High-level architecture diagrams
  - Component architecture (frontend & backend)
  - Data architecture and database schema
  - API design and endpoints
  - Integration architecture
  - Security architecture
  - Deployment architecture
  - Scalability and performance
  - Design patterns
  - Architecture Decision Records (ADRs)

### API Documentation

Supabase provides **auto-generated API documentation** based on your database schema:

**Local Development:**
- **Supabase Studio**: http://localhost:54323
- **API Reference**: Auto-generated PostgREST API documentation in Supabase Studio
- **Database Schema**: View in Studio → Database section

**Production:**
- **Supabase Dashboard**: https://app.supabase.com
- **API Docs**: Available in your project dashboard → API section
- **Auto-generated TypeScript types**: Run `supabase gen types typescript` to generate types from your database schema

---

## 🗺 Roadmap

### Current Status: Phase 0 - Planning ✅

All planning documents complete. Supabase architecture finalized. Ready to begin implementation.

### Implementation Timeline (16-20 weeks)

**Note:** Using Supabase significantly reduces development time compared to building a custom backend.

#### Phase 0: Project Setup (Week 1) - **NEXT**
- Create Supabase project and configure
- Initialize React + TypeScript with Vite
- Create database migrations (SQL)
- Set up Row-Level Security (RLS) policies
- Configure Supabase client in frontend

#### Phase 1-2: Core Database & Frontend (Week 2-3)
- Customer and Order tables with RLS
- Authentication UI (Supabase Auth)
- Main layout and navigation
- Customer management UI
- Real-time subscriptions

#### Phase 3-4: Activities & Analytics (Week 4-5)
- Activity tracking table and UI
- Order management UI
- Basic analytics dashboard
- File uploads (Supabase Storage)

#### Phase 5-6: Edge Functions & Integrations (Week 6-8)
- Shopify sync Edge Function
- Shopify webhook handler
- Email sending Edge Function
- Integration management UI

#### Phase 7-8: Advanced Features (Week 9-11)
- Customer segmentation
- Bulk operations
- Team management
- Advanced analytics

#### Phase 9-10: Testing & Security (Week 12-14)
- Comprehensive testing (>80% coverage)
- RLS policy audit
- Security review
- Performance optimization

#### Phase 11-12: Production & Launch (Week 15-16)
- Deploy to Vercel/Netlify
- CI/CD pipeline setup
- Monitoring and logging
- Production testing

#### Phase 13+: Post-Launch (Week 17+)
- WooCommerce integration
- Workflow automation
- PWA support
- ML-powered insights
- User feedback iteration

**Target MVP Launch**: Week 11-12 (Core functionality)
**Full Launch**: Week 16 (All features)
**Advanced Features**: Week 17+ (Ongoing)

For detailed week-by-week breakdown, see [SYSTEM_SPEC.md - Section 10](SYSTEM_SPEC.md#10-implementation-phases).

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Write tests** for your changes
5. **Ensure all tests pass** (`npm test` for frontend, `deno test` for Edge Functions)
6. **Commit your changes** (`git commit -m 'feat: add amazing feature'`)
7. **Push to the branch** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request**

### Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add customer segmentation feature
fix: resolve authentication token refresh issue
docs: update API documentation for orders endpoint
```

### Code Review Process

1. All PRs require at least one approval
2. All tests must pass
3. Code coverage must not decrease
4. Follow the project's code style guidelines

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [Django](https://www.djangoproject.com/) and [React](https://react.dev/)
- UI components from [shadcn/ui](https://ui.shadcn.com/)
- Icons from [Lucide](https://lucide.dev/)
- Inspired by modern CRM best practices

---

## 📞 Support

For questions, issues, or feature requests:

- **Issues**: [GitHub Issues](https://github.com/hahahaallday/simple-crm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/hahahaallday/simple-crm/discussions)
- **Documentation**: See [SYSTEM_SPEC.md](SYSTEM_SPEC.md) and [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 🌟 Star History

If you find this project useful, please consider giving it a star ⭐

---

**Built with ❤️ for cross-border ecommerce teams worldwide**
