export type UserRole = 'member' | 'librarian'

export interface User {
  id: number
  name: string
  email: string
  role: UserRole
}

export interface Book {
  id: number
  title: string
  author: string
  genre: string
  isbn: string
  total_copies: number
  available_copies: number
  created_at: string
  updated_at: string
}

export interface BorrowingUser {
  id: number
  name: string
  email: string
}

export interface BorrowingBook {
  id: number
  title: string
  author: string
}

export interface Borrowing {
  id: number
  book: BorrowingBook
  user: BorrowingUser
  borrowed_at: string
  due_date: string
  returned_at: string | null
  overdue: boolean
  status: 'active' | 'overdue' | 'returned'
}

export interface LibrarianDashboard {
  total_books: number
  total_borrowed: number
  books_due_today: number
  overdue_members: {
    user: BorrowingUser
    overdue_books: {
      borrowing_id: number
      book: BorrowingBook
      due_date: string
      days_overdue: number
    }[]
  }[]
}

export interface MemberDashboard {
  borrowed_books: MemberBorrowing[]
  overdue_books: MemberBorrowing[]
}

export interface MemberBorrowing {
  id: number
  book: BorrowingBook
  borrowed_at: string
  due_date: string
  overdue: boolean
  status: 'active' | 'overdue'
}

export interface AuthResponse {
  token: string
  user: User
}

export interface ApiError {
  error?: string
  errors?: string[]
}
