import { Link } from 'react-router-dom'
import { Button } from '../ui/Button'
import type { Book } from '../../lib/types'

interface BookCardProps {
  book: Book
  isLibrarian: boolean
  onBorrow?: (book: Book) => void
  onDelete?: (book: Book) => void
}

export function BookCard({ book, isLibrarian, onBorrow, onDelete }: BookCardProps) {
  const available = book.available_copies > 0

  return (
    <div className="bg-white rounded-xl border border-gray-200 p-5 flex flex-col gap-3 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 min-w-0">
          <h3 className="font-semibold text-gray-900 truncate">{book.title}</h3>
          <p className="text-sm text-gray-500">{book.author}</p>
        </div>
        <span className="text-xs px-2 py-0.5 rounded-full bg-gray-100 text-gray-600 shrink-0">
          {book.genre}
        </span>
      </div>

      <p className="text-xs text-gray-400">ISBN: {book.isbn}</p>

      <div className="flex items-center justify-between pt-1 border-t border-gray-100">
        <span className={`text-sm font-medium ${available ? 'text-green-600' : 'text-red-500'}`}>
          {available ? `${book.available_copies} / ${book.total_copies} available` : 'Unavailable'}
        </span>

        <div className="flex gap-2">
          {isLibrarian ? (
            <>
              <Link to={`/books/${book.id}/edit`}>
                <Button variant="secondary" className="text-xs px-3 py-1">Edit</Button>
              </Link>
              <Button
                variant="danger"
                className="text-xs px-3 py-1"
                onClick={() => onDelete?.(book)}
              >
                Delete
              </Button>
            </>
          ) : (
            <Button
              variant="primary"
              className="text-xs px-3 py-1"
              disabled={!available}
              onClick={() => onBorrow?.(book)}
            >
              Borrow
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}
