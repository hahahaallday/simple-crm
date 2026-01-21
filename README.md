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

### Backend

- **Framework**: Django 5.0 + Django REST Framework
- **Language**: Python 3.11+
- **Database**: PostgreSQL 16 (primary data store)
- **Cache**: Redis 7.x (cache, sessions, queue)
- **Task Queue**: Celery (background jobs)
- **Authentication**: JWT (djangorestframework-simplejwt)
- **API Documentation**: drf-spectacular (OpenAPI 3.0)

**Key Python Packages:**
```
Django==5.0.1
djangorestframework==3.14.0
djangorestframework-simplejwt==5.3.1
psycopg2-binary==2.9.9
celery==5.3.6
redis==5.0.1
shopify-python-api==12.4.0
sendgrid==6.11.0
```

### Frontend

- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite (fast HMR)
- **State Management**: Zustand (lightweight)
- **UI Components**: Tailwind CSS + shadcn/ui
- **HTTP Client**: Axios
- **Routing**: React Router v6
- **Forms**: React Hook Form + Zod validation
- **Charts**: Recharts
- **Date Handling**: date-fns with timezone support

**Key NPM Packages:**
```json
{
  "react": "^18.2.0",
  "react-router-dom": "^6.21.1",
  "zustand": "^4.4.7",
  "axios": "^1.6.5",
  "tailwindcss": "^3.4.1",
  "recharts": "^2.10.3"
}
```

### DevOps

- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry (error tracking)
- **Testing**: pytest (backend), Vitest (frontend)

---

## 🏗 Architecture

This CRM follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│     Presentation Layer (React)          │
│  - UI Components, State Management      │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│        API Layer (DRF)                  │
│  - Authentication, Rate Limiting        │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│   Business Logic Layer (Django Apps)    │
│  - Services, ViewSets, Serializers      │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│   Data Layer (PostgreSQL + Redis)      │
│  - Database, Cache, Queue               │
└─────────────────────────────────────────┘
```

**Key Architectural Decisions:**

- **API-First Design**: RESTful API as the contract between frontend and backend
- **Service Layer Pattern**: Business logic separated from views
- **Asynchronous Processing**: Celery for long-running tasks (sync, email, webhooks)
- **Stateless Services**: JWT authentication, no server-side sessions
- **Security by Default**: HTTPS, CORS, rate limiting, RBAC

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 📁 Project Structure

```
simple-crm/
├── backend/                    # Django backend
│   ├── config/                # Project configuration
│   │   ├── settings/
│   │   │   ├── base.py        # Base settings
│   │   │   ├── development.py # Dev settings
│   │   │   └── production.py  # Prod settings
│   │   ├── urls.py            # Root URL config
│   │   └── celery.py          # Celery config
│   ├── apps/                  # Django applications
│   │   ├── customers/         # Customer management
│   │   ├── orders/            # Order management
│   │   ├── activities/        # Activity tracking
│   │   ├── users/             # User management
│   │   ├── analytics/         # Analytics & reports
│   │   ├── integrations/      # Integration framework
│   │   └── communications/    # Email & templates
│   ├── requirements/
│   │   ├── base.txt           # Base dependencies
│   │   ├── development.txt    # Dev dependencies
│   │   └── production.txt     # Prod dependencies
│   ├── manage.py
│   └── pytest.ini
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/        # Reusable components
│   │   ├── features/          # Feature modules
│   │   │   ├── customers/
│   │   │   ├── orders/
│   │   │   ├── activities/
│   │   │   ├── analytics/
│   │   │   └── settings/
│   │   ├── layouts/           # Page layouts
│   │   ├── pages/             # Route pages
│   │   ├── store/             # Zustand stores
│   │   ├── services/          # API services
│   │   ├── utils/             # Utilities
│   │   ├── types/             # TypeScript types
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── tailwind.config.js
│
├── docker-compose.yml          # Docker Compose config
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

- **Docker** (recommended) or manual setup:
  - Python 3.11+
  - Node.js 18+
  - PostgreSQL 16
  - Redis 7.x

### Quick Start with Docker (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/hahahaallday/simple-crm.git
   cd simple-crm
   ```

2. **Copy environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start services**
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**
   ```bash
   docker-compose exec backend python manage.py migrate
   ```

5. **Create superuser**
   ```bash
   docker-compose exec backend python manage.py createsuperuser
   ```

6. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000/api/v1/
   - API Documentation: http://localhost:8000/api/docs/
   - Django Admin: http://localhost:8000/admin/

### Manual Setup (Without Docker)

#### Backend Setup

1. **Create virtual environment**
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements/development.txt
   ```

3. **Set up environment variables**
   ```bash
   export DATABASE_URL="postgresql://user:password@localhost:5432/crm_db"
   export REDIS_URL="redis://localhost:6379/0"
   export SECRET_KEY="your-secret-key"
   export DEBUG=True
   ```

4. **Run migrations**
   ```bash
   python manage.py migrate
   ```

5. **Create superuser**
   ```bash
   python manage.py createsuperuser
   ```

6. **Start development server**
   ```bash
   python manage.py runserver
   ```

7. **Start Celery worker** (in another terminal)
   ```bash
   celery -A config worker -l info
   ```

#### Frontend Setup

1. **Install dependencies**
   ```bash
   cd frontend
   npm install
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your backend API URL
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

---

## 💻 Development

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Backend: Modify Django apps in `backend/apps/`
   - Frontend: Modify React components in `frontend/src/`

3. **Run tests**
   ```bash
   # Backend tests
   cd backend
   pytest

   # Frontend tests
   cd frontend
   npm test
   ```

4. **Run linters**
   ```bash
   # Backend (Python)
   black .
   flake8

   # Frontend (TypeScript)
   npm run lint
   npm run format
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

6. **Push and create pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style

**Backend (Python):**
- Follow PEP 8
- Use Black for formatting
- Use type hints where applicable
- Max line length: 100 characters

**Frontend (TypeScript):**
- Follow Airbnb style guide
- Use ESLint + Prettier
- Use TypeScript strict mode
- Prefer functional components with hooks

### Database Migrations

**Create migration:**
```bash
python manage.py makemigrations
```

**Apply migrations:**
```bash
python manage.py migrate
```

**Rollback migration:**
```bash
python manage.py migrate app_name previous_migration_name
```

### API Development

**Adding a new endpoint:**

1. Create model in `models.py`
2. Create serializer in `serializers.py`
3. Create viewset in `views.py`
4. Register URLs in `urls.py`
5. Add tests in `tests/`

**Example:**
```python
# models.py
class Customer(models.Model):
    email = models.EmailField(unique=True)
    # ... other fields

# serializers.py
class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

# views.py
class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
    permission_classes = [IsAuthenticated]
```

---

## 🧪 Testing

### Backend Testing

**Run all tests:**
```bash
cd backend
pytest
```

**Run specific test file:**
```bash
pytest apps/customers/tests/test_models.py
```

**Run with coverage:**
```bash
pytest --cov=apps --cov-report=html
```

**Test structure:**
```
apps/customers/tests/
├── __init__.py
├── test_models.py
├── test_serializers.py
├── test_views.py
└── test_services.py
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

### Testing Strategy

- **Unit Tests**: Test individual functions, components, models
- **Integration Tests**: Test API endpoints, database queries
- **E2E Tests**: Test complete user flows (planned with Playwright)
- **Target Coverage**: >80%

---

## 🚢 Deployment

### Production Deployment with Docker

1. **Build production images**
   ```bash
   docker build -t crm-backend:latest -f backend/Dockerfile.prod ./backend
   docker build -t crm-frontend:latest -f frontend/Dockerfile.prod ./frontend
   ```

2. **Set production environment variables**
   ```bash
   export DEBUG=False
   export SECRET_KEY="your-production-secret-key"
   export DATABASE_URL="postgresql://..."
   export ALLOWED_HOSTS="yourdomain.com,www.yourdomain.com"
   ```

3. **Run migrations**
   ```bash
   docker-compose -f docker-compose.prod.yml run backend python manage.py migrate
   ```

4. **Collect static files**
   ```bash
   docker-compose -f docker-compose.prod.yml run backend python manage.py collectstatic --noinput
   ```

5. **Start production services**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Environment Variables

**Required:**
- `SECRET_KEY`: Django secret key
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts

**Optional:**
- `DEBUG`: Set to `False` in production
- `SENDGRID_API_KEY`: SendGrid API key for email
- `SHOPIFY_API_KEY`: Shopify integration key
- `SHOPIFY_API_SECRET`: Shopify integration secret
- `SENTRY_DSN`: Sentry error tracking DSN
- `AWS_ACCESS_KEY_ID`: AWS S3 access key
- `AWS_SECRET_ACCESS_KEY`: AWS S3 secret key
- `AWS_STORAGE_BUCKET_NAME`: S3 bucket name

See `.env.example` for complete list.

### CI/CD Pipeline

GitHub Actions automatically:
- Runs tests on every push
- Builds Docker images
- Deploys to production on merge to `main`

See `.github/workflows/deploy.yml` for configuration.

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

Interactive API documentation is available at:
- **Swagger UI**: http://localhost:8000/api/docs/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

---

## 🗺 Roadmap

### Current Status: Phase 0 - Planning ✅

All planning documents complete. Ready to begin implementation.

### Implementation Timeline (24 weeks)

#### Phase 0: Project Setup (Week 1) - **NEXT**
- Set up Django project with multi-environment settings
- Initialize React + TypeScript with Vite
- Configure Docker Compose
- Set up Celery and Redis
- Create base project structure

#### Phase 1-2: Core Backend (Week 2-3)
- Customer and Order models
- Django REST Framework API
- JWT authentication
- Role-based access control

#### Phase 3-4: Frontend Foundation (Week 4-5)
- Authentication UI
- Main layout and navigation
- Customer management UI
- Reusable component library

#### Phase 5-6: Activities & Orders (Week 5-6)
- Activity tracking
- Order management UI
- File attachments

#### Phase 7-8: Integrations (Week 7-9)
- Shopify OAuth and sync
- Email integration (SendGrid/AWS SES)
- Webhook processing

#### Phase 9-11: Analytics (Week 9-13)
- Analytics dashboard
- Customer segmentation
- Bulk operations
- Team management

#### Phase 12-13: Testing & Security (Week 13-15)
- Comprehensive testing (>80% coverage)
- GDPR compliance
- Security audit
- Penetration testing

#### Phase 14-15: Deployment (Week 15-17)
- Performance optimization
- Production deployment
- CI/CD pipeline
- Monitoring setup

#### Phase 16-20: Advanced Features (Week 17-24)
- WooCommerce integration
- Workflow automation
- PWA support
- ML-powered insights (churn prediction, LTV)
- Final polish and launch

**Target Launch**: Week 24 (Full Production)
**MVP Launch**: Week 12 (Basic functionality)

For detailed week-by-week breakdown, see [SYSTEM_SPEC.md - Section 10](SYSTEM_SPEC.md#10-implementation-phases).

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Write tests** for your changes
5. **Ensure all tests pass** (`pytest` and `npm test`)
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
