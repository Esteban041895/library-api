# Library API

A full-stack library management system built with **Ruby on Rails** (API) and **React** (frontend). Supports two user roles — **Librarian** and **Member** — with JWT authentication, book catalog management, borrowing/returning workflows, and role-specific dashboards.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Ruby on Rails 7.2 (API mode) |
| Database | PostgreSQL |
| Auth | JWT + token versioning (server-side logout) |
| Authorization | Pundit |
| Backend Testing | RSpec, FactoryBot, Shoulda Matchers |
| Frontend | React 19, TypeScript, Vite |
| Styling | Tailwind CSS |
| State | React Query + Context API |
| Frontend Testing | Vitest, React Testing Library |

---

## Requirements

- Ruby `3.x` (see `.ruby-version`)
- Node.js `18+`
- PostgreSQL `14+`

---

## Setup

### 1. Clone the repo

```bash
git clone <repo-url>
cd library-api
```

### 2. Install backend dependencies

```bash
bundle install
```

### 3. Configure the database

Create a `config/database.yml` if it doesn't exist, or confirm your PostgreSQL credentials are correct. Then:

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Install frontend dependencies

```bash
cd frontend
npm install
cd ..
```

---

## Running the app

### Backend

```bash
rails server
```

API available at `http://localhost:3000`

### Frontend

```bash
cd frontend
npm run dev
```

Frontend available at `http://localhost:5173`

---

## Demo Credentials

Seeded automatically by `rails db:seed`:

| Role | Email | Password |
|------|-------|----------|
| Librarian | `librarian@library.com` | `password123` |
| Member | `member1@library.com` | `password123` |
| Member | `member2@library.com` | `password123` |

---

## Running Tests

### Backend

```bash
bundle exec rspec
```

Run a specific file:

```bash
bundle exec rspec spec/requests/api/v1/books_spec.rb
```

Run with documentation format:

```bash
bundle exec rspec --format documentation
```

### Frontend

```bash
cd frontend
npm test
```

Run in watch mode:

```bash
npm run test:watch
```

Run with coverage report:

```bash
npm run test:coverage
```

---

## API Reference

All endpoints are prefixed with `/api/v1`. Authenticated endpoints require:

```
Authorization: Bearer <token>
```

### Authentication

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/register` | No | Create account |
| POST | `/login` | No | Log in |
| DELETE | `/logout` | Yes | Invalidate token |

### Books

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/books` | Any | List all books (supports `?search=`) |
| GET | `/books/:id` | Any | Get a book |
| POST | `/books` | Librarian | Add a book |
| PATCH | `/books/:id` | Librarian | Update a book |
| DELETE | `/books/:id` | Librarian | Delete a book |

### Borrowings

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/borrowings` | Any | List borrowings (scoped by role) |
| POST | `/borrowings` | Member | Borrow a book |
| PATCH | `/borrowings/:id/return` | Librarian | Mark as returned |

### Dashboard

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/dashboard` | Any | Role-specific dashboard stats |

---

## Project Structure

```
library-api/
├── app/
│   ├── controllers/
│   │   ├── api/v1/
│   │   │   ├── authentication_controller.rb
│   │   │   ├── books_controller.rb
│   │   │   ├── borrowings_controller.rb
│   │   │   └── dashboard_controller.rb
│   │   └── concerns/
│   │       └── authenticatable.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── book.rb
│   │   └── borrowing.rb
│   ├── policies/
│   │   ├── book_policy.rb
│   │   └── borrowing_policy.rb
│   └── services/
│       └── jwt_service.rb
├── db/
│   ├── migrate/
│   └── seeds.rb
├── spec/
│   ├── factories/
│   ├── models/
│   ├── policies/
│   ├── requests/api/v1/
│   └── services/
└── frontend/
    └── src/
        ├── components/
        ├── context/
        ├── hooks/
        ├── lib/
        ├── pages/
        └── test/
```

---

## User Stories

See [USER_STORIES.md](./USER_STORIES.md) for the full list of epics and user stories with acceptance criteria.
