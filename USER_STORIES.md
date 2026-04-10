# Library API — User Stories

## Epic 1 — Authentication & Authorization

### US-01 · Register ✅
> **Commit:** `feat: US-01 - Register`

**As a** visitor, **I want to** create an account by providing my name, email, and password, **so that** I can access the library system.

**Acceptance Criteria:**
- `POST /api/v1/register` accepts `{ name, email, password, password_confirmation }`
- Returns JWT token + user role on success (`201 Created`)
- Returns `422` with field errors on invalid input
- Email must be unique — `422` on duplicate
- Default role is `member` unless specified

**Key files:**
- `app/controllers/api/v1/authentication_controller.rb`
- `app/services/jwt_service.rb`
- `spec/services/jwt_service_spec.rb`
- `spec/requests/api/v1/authentication_spec.rb`

---

### US-02 · Login ✅
> **Commit:** `feat: US-02 - Login`

**As a** registered user, **I want to** log in with my email and password, **so that** I can access my account.

**Acceptance Criteria:**
- `POST /api/v1/login` accepts `{ email, password }`
- Returns JWT + role on success (`200 OK`)
- Returns `401` on bad credentials with message `"Invalid email or password"`

**Key files:**
- `app/controllers/api/v1/authentication_controller.rb`
- `spec/requests/api/v1/authentication_spec.rb`

---

### US-03 · Logout ✅
> **Commit:** `feat: US-03 - Logout`

**As a** logged-in user, **I want to** log out, **so that** my session is invalidated on the server.

**Acceptance Criteria:**
- `DELETE /api/v1/logout` invalidates the JWT server-side
- Returns `204 No Content`
- Any subsequent request with the old token returns `401 "Token has been revoked"`
- Implemented via `token_version` on the User model — incremented on logout

**Key files:**
- `app/controllers/api/v1/authentication_controller.rb`
- `app/controllers/concerns/authenticatable.rb`
- `db/migrate/20260409000001_add_token_version_to_users.rb`
- `spec/requests/api/v1/authentication_spec.rb`

---

### US-04 · Role-Based Access Control ✅
> **Commit:** `feat: US-04 - Role-Based Access Control`

**As the** system, **I want to** enforce that only Librarians can mutate book data, **so that** Members cannot alter the catalog.

**Acceptance Criteria:**
- `User` model has a `role` enum: `member` (0), `librarian` (1)
- Librarians: full CRUD on books
- Members: read-only on books, can borrow
- Unauthorized attempts return `403 Forbidden`
- Authorization enforced via Pundit policies

**Key files:**
- `app/models/user.rb`
- `app/policies/application_policy.rb`
- `app/policies/book_policy.rb`
- `app/policies/borrowing_policy.rb`
- `spec/models/user_spec.rb`

---

## Epic 2 — Book Management

### US-05 · Add Book ✅
> **Commit:** `feat: US-05 - Add Book`

**As a** Librarian, **I want to** add a new book to the catalog, **so that** Members can discover and borrow it.

**Acceptance Criteria:**
- `POST /api/v1/books` requires `title`, `author`, `genre`, `isbn`, `total_copies`
- Returns `201` with book JSON on success
- Returns `422` for missing or invalid fields
- ISBN must be unique
- Returns `403` if called by a Member

**Key files:**
- `app/controllers/api/v1/books_controller.rb`
- `app/models/book.rb`
- `spec/requests/api/v1/books_spec.rb`

---

### US-06 · Edit Book ✅
> **Commit:** `feat: US-06 - Edit Book`

**As a** Librarian, **I want to** edit book details, **so that** the catalog stays accurate.

**Acceptance Criteria:**
- `PATCH /api/v1/books/:id` updates any subset of book fields
- Returns `200` with updated book JSON
- Returns `403` if called by a Member

**Key files:**
- `app/controllers/api/v1/books_controller.rb`
- `spec/requests/api/v1/books_spec.rb`

---

### US-07 · Delete Book ✅
> **Commit:** `feat: US-07 - Delete Book`

**As a** Librarian, **I want to** delete a book from the catalog, **so that** obsolete entries are removed.

**Acceptance Criteria:**
- `DELETE /api/v1/books/:id` removes the book
- Returns `204 No Content`
- Returns `403` if called by a Member

**Key files:**
- `app/controllers/api/v1/books_controller.rb`
- `spec/requests/api/v1/books_spec.rb`

---

### US-08 · Browse Books ✅
> **Commit:** `feat: US-08, US-09 - Browse and Search Books`

**As an** authenticated user, **I want to** see the list of available books, **so that** I can decide what to borrow.

**Acceptance Criteria:**
- `GET /api/v1/books` returns the full list of books
- `GET /api/v1/books/:id` returns a single book
- Each record includes `title`, `author`, `genre`, `isbn`, `total_copies`, `available_copies`
- Returns `401` for unauthenticated requests
- Returns `404` for a non-existent book ID

**Key files:**
- `app/controllers/api/v1/books_controller.rb`
- `app/policies/book_policy.rb`
- `spec/requests/api/v1/books_spec.rb`

---

### US-09 · Search Books ✅
> **Commit:** `feat: US-08, US-09 - Browse and Search Books`

**As an** authenticated user, **I want to** search books by title, author, or genre, **so that** I can find what I'm looking for quickly.

**Acceptance Criteria:**
- `GET /api/v1/books?search=term` filters case-insensitively across `title`, `author`, and `genre`
- Blank or missing `search` param returns all books

**Key files:**
- `app/models/book.rb` — `Book.search` scope with `ILIKE`
- `spec/models/book_spec.rb`

---

## Epic 3 — Borrowing & Returning

### US-10 · Borrow a Book ✅
> **Commit:** `feat: US-10, US-11 - Borrow a Book`

**As a** Member, **I want to** borrow an available book, **so that** I can read it.

**Acceptance Criteria:**
- `POST /api/v1/borrowings` creates a borrowing record
- `borrowed_at` = today, `due_date` = today + 14 days
- Returns `201` with borrowing JSON
- Returns `422` if no copies are available
- Returns `403` if called by a Librarian

**Key files:**
- `app/controllers/api/v1/borrowings_controller.rb`
- `app/policies/borrowing_policy.rb`
- `spec/requests/api/v1/borrowings_spec.rb`

---

### US-11 · Prevent Duplicate Borrowing ✅
> **Commit:** `feat: US-10, US-11 - Borrow a Book`

**As the** system, **I want to** prevent a Member from borrowing the same book twice, **so that** the inventory stays consistent.

**Acceptance Criteria:**
- If an active (non-returned) borrowing exists for the same user + book, returns `422`
- Error message: `"Book is already borrowed by this member"`
- Validated at the model level, not just the controller

**Key files:**
- `app/models/borrowing.rb` — `no_active_borrowing_for_same_book` validator
- `spec/models/borrowing_spec.rb`

---

### US-12 · Return a Book ✅
> **Commit:** `feat: US-12 - Return a Book`

**As a** Librarian, **I want to** mark a borrowed book as returned, **so that** it becomes available again.

**Acceptance Criteria:**
- `PATCH /api/v1/borrowings/:id/return` sets `returned_at` = today
- Returns `200` with updated borrowing JSON
- Returns `422` if the book was already returned
- Returns `403` if called by a Member

**Key files:**
- `app/controllers/api/v1/borrowings_controller.rb`
- `app/policies/borrowing_policy.rb`
- `spec/policies/borrowing_policy_spec.rb`
- `spec/requests/api/v1/borrowings_spec.rb`

---

### US-13 · View My Borrowings ✅
> **Commit:** `feat: US-13 - View My Borrowings`

**As an** authenticated user, **I want to** see all borrowings, **so that** I can track due dates and returns.

**Acceptance Criteria:**
- `GET /api/v1/borrowings` returns scoped results
- Librarians see all borrowings across all members
- Members see only their own borrowings
- Each record includes book, user, `borrowed_at`, `due_date`, `returned_at`, and `status`
- Returns `401` for unauthenticated requests

**Key files:**
- `app/controllers/api/v1/borrowings_controller.rb`
- `app/policies/borrowing_policy.rb` — `Scope#resolve`
- `spec/requests/api/v1/borrowings_spec.rb`

---

## Epic 4 — Dashboards

### US-14 · Librarian Dashboard ✅
> **Commit:** `feat: US-14 - Librarian Dashboard`

**As a** Librarian, **I want** a dashboard overview, **so that** I can monitor the library's status at a glance.

**Acceptance Criteria:**
- `GET /api/v1/dashboard` (Librarian) returns:
  - `total_books` — count of all books in the catalog
  - `total_borrowed` — count of active borrowings
  - `books_due_today` — count of borrowings due today
  - `overdue_members` — list of members with overdue books, including book title and days overdue

**Key files:**
- `app/controllers/api/v1/dashboard_controller.rb`
- `spec/requests/api/v1/dashboard_spec.rb`

---

### US-15 · Member Dashboard ✅
> **Commit:** `feat: US-15 - Member Dashboard`

**As a** Member, **I want** a personal dashboard, **so that** I can see my borrowing activity and any overdue items.

**Acceptance Criteria:**
- `GET /api/v1/dashboard` (Member) returns:
  - `borrowed_books` — active borrowings with due dates
  - `overdue_books` — borrowings past the due date
- Does not expose other members' data

**Key files:**
- `app/controllers/api/v1/dashboard_controller.rb`
- `spec/requests/api/v1/dashboard_spec.rb`

---

## Epic 5 — Frontend

### US-16 · Login UI ✅
> **Commit:** `feat: US-16 - Login UI`

**As a** user, **I want** a login form, **so that** I can sign in from the browser.

**Acceptance Criteria:**
- Email + password form with validation feedback
- Redirects to dashboard on successful login
- Shows inline error message on invalid credentials
- Mobile-responsive layout

**Key files:**
- `frontend/src/pages/LoginPage.tsx`
- `frontend/src/context/AuthContext.tsx`
- `frontend/src/lib/api.ts`

---

### US-17 · Registration UI ✅
> **Commit:** `feat: US-17 - Registration UI`

**As a** visitor, **I want** a registration form, **so that** I can create an account from the browser.

**Acceptance Criteria:**
- Name, email, password fields
- Redirects to dashboard on successful registration
- Shows field-level errors on failure

**Key files:**
- `frontend/src/pages/RegisterPage.tsx`

---

### US-18 · Book Catalog UI ✅
> **Commit:** `feat: US-18 - Book Catalog UI`

**As any** user, **I want to** browse and search books in the browser, **so that** I can find what to borrow.

**Acceptance Criteria:**
- Responsive grid of book cards (1 col mobile → 3 cols desktop)
- Search bar filters results
- Each card shows title, author, genre, and available copies

**Key files:**
- `frontend/src/pages/BooksPage.tsx`
- `frontend/src/components/books/BookCard.tsx`
- `frontend/src/components/books/SearchBar.tsx`

---

### US-19 · Book Management UI ✅
> **Commit:** `feat: US-19 - Book Management UI`

**As a** Librarian, **I want to** add, edit, and delete books from the browser, **so that** I can manage the catalog without API tools.

**Acceptance Criteria:**
- Add/Edit form with all required fields
- Delete button with confirmation
- Librarian-only controls are hidden from Members

**Key files:**
- `frontend/src/pages/BookFormPage.tsx`

---

### US-20 · Borrowings UI ✅
> **Commit:** `feat: US-20, US-21 - Borrowings UI`

**As a** Member, **I want to** view my borrowing history from the browser, **so that** I can track what I've borrowed and when it's due.

**Acceptance Criteria:**
- Borrowings list shows book title, borrowed date, due date, and status
- Overdue borrowings are visually highlighted

**Key files:**
- `frontend/src/pages/BorrowingsPage.tsx`

---

### US-21 · Return UI ✅
> **Commit:** `feat: US-20, US-21 - Borrowings UI`

**As a** Librarian, **I want to** mark books as returned from the browser, **so that** inventory updates instantly.

**Acceptance Criteria:**
- Borrowings list shows all active loans
- "Mark returned" button triggers the return API
- Row updates immediately on success

**Key files:**
- `frontend/src/pages/BorrowingsPage.tsx`

**Note:** US-20 and US-21 share the same commit because both are implemented within `BorrowingsPage.tsx`. The page renders the return button conditionally based on the user's role.

---

### US-22 · Dashboard UI ✅
> **Commit:** `feat: US-22 - Dashboard UI`

**As any** user, **I want to** see a role-appropriate dashboard when I log in, **so that** I have an immediate overview of my activity.

**Acceptance Criteria:**
- Librarian sees stat cards (total books, borrowed, due today) + overdue members table
- Member sees borrowed books and overdue books lists
- Responsive layout

**Key files:**
- `frontend/src/pages/DashboardPage.tsx`

---

## Epic 6 — Documentation & Ops

### US-23 · Setup and Seed Data ✅
> **Commit:** `feat: US-23 - Setup and Seed Data`

**As a** developer evaluating this project, **I want** seed data with demo credentials, **so that** I can test the application immediately without manual setup.

**Acceptance Criteria:**
- `db/seeds.rb` creates demo users and books on `rails db:seed`
- Demo credentials:
  - `librarian@library.com` / `password123`
  - `member1@library.com` / `password123`
  - `member2@library.com` / `password123`
- 15 books across multiple genres
- Sample borrowings including overdue scenarios

**Key files:**
- `db/seeds.rb`
- `config/initializers/cors.rb`

---

### US-24 · README Setup Guide ✅
> **Commit:** `feat: US-24 - README Setup Guide`

**As a** developer evaluating this project, **I want** clear setup instructions in the README, **so that** I can run the project locally without guessing.

**Acceptance Criteria:**
- Ruby + Node.js version requirements documented
- Database setup steps: `rails db:create db:migrate db:seed`
- How to start the backend: `rails server`
- How to start the frontend: `cd frontend && npm install && npm run dev`
- How to run the test suite: `bundle exec rspec`
- Demo credentials listed

**Key files:**
- `README.md`
