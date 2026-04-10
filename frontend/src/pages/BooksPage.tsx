import { useState, useCallback } from 'react'
import { Link } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '../lib/api'
import { useAuth } from '../context/AuthContext'
import { BookCard } from '../components/books/BookCard'
import { SearchBar } from '../components/books/SearchBar'
import { Button } from '../components/ui/Button'
import { Alert } from '../components/ui/Alert'
import type { Book, ApiError } from '../lib/types'
import axios from 'axios'

export function BooksPage() {
  const { isLibrarian } = useAuth()
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null)

  const { data: books = [], isLoading } = useQuery({
    queryKey: ['books', search],
    queryFn: async () => {
      const { data } = await api.get<Book[]>('/books', { params: search ? { search } : {} })
      return data
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => api.delete(`/books/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] })
      setFeedback({ type: 'success', message: 'Book deleted.' })
    },
    onError: () => setFeedback({ type: 'error', message: 'Failed to delete book.' }),
  })

  const borrowMutation = useMutation({
    mutationFn: (bookId: number) => api.post('/borrowings', { borrowing: { book_id: bookId } }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] })
      setFeedback({ type: 'success', message: 'Book borrowed! Due in 2 weeks.' })
    },
    onError: (err: unknown) => {
      if (axios.isAxiosError(err)) {
        const data = err.response?.data as ApiError
        setFeedback({ type: 'error', message: (data?.errors ?? [data?.error ?? 'Failed to borrow']).join(', ') })
      }
    },
  })

  const handleSearch = useCallback((q: string) => setSearch(q), [])

  const handleDelete = (book: Book) => {
    if (confirm(`Delete "${book.title}"? This cannot be undone.`)) {
      deleteMutation.mutate(book.id)
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-900">Books</h1>
        {isLibrarian && (
          <Link to="/books/new">
            <Button>+ Add book</Button>
          </Link>
        )}
      </div>

      <SearchBar onSearch={handleSearch} />

      {feedback && (
        <Alert
          type={feedback.type}
          message={feedback.message}
        />
      )}

      {isLoading ? (
        <p className="text-gray-400 text-sm">Loading…</p>
      ) : books.length === 0 ? (
        <p className="text-gray-400 text-sm">No books found.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {books.map((book) => (
            <BookCard
              key={book.id}
              book={book}
              isLibrarian={isLibrarian}
              onBorrow={(b) => borrowMutation.mutate(b.id)}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}
    </div>
  )
}
