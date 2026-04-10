import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { api } from '../lib/api'
import { useAuth } from '../context/AuthContext'
import { Button } from '../components/ui/Button'
import { Alert } from '../components/ui/Alert'
import type { Borrowing } from '../lib/types'
import { useState } from 'react'

const statusBadge: Record<string, string> = {
  active: 'bg-green-100 text-green-700',
  overdue: 'bg-red-100 text-red-700',
  returned: 'bg-gray-100 text-gray-500',
}

export function BorrowingsPage() {
  const { isLibrarian } = useAuth()
  const queryClient = useQueryClient()
  const [feedback, setFeedback] = useState('')

  const { data: borrowings = [], isLoading } = useQuery({
    queryKey: ['borrowings'],
    queryFn: async () => {
      const { data } = await api.get<Borrowing[]>('/borrowings')
      return data
    },
  })

  const returnMutation = useMutation({
    mutationFn: (id: number) => api.patch(`/borrowings/${id}/return`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['borrowings'] })
      queryClient.invalidateQueries({ queryKey: ['books'] })
      setFeedback('Book marked as returned.')
    },
  })

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-2xl font-semibold text-gray-900">Borrowings</h1>

      {feedback && <Alert type="success" message={feedback} />}

      {isLoading ? (
        <p className="text-gray-400 text-sm">Loading…</p>
      ) : borrowings.length === 0 ? (
        <p className="text-gray-400 text-sm">No borrowings found.</p>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50 text-left text-xs text-gray-500 uppercase tracking-wide">
                <th className="px-4 py-3">Book</th>
                {isLibrarian && <th className="px-4 py-3">Member</th>}
                <th className="px-4 py-3">Borrowed</th>
                <th className="px-4 py-3">Due</th>
                <th className="px-4 py-3">Status</th>
                {isLibrarian && <th className="px-4 py-3"></th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {borrowings.map((b) => (
                <tr key={b.id} className={b.status === 'overdue' ? 'bg-red-50' : ''}>
                  <td className="px-4 py-3 font-medium text-gray-900">{b.book.title}</td>
                  {isLibrarian && <td className="px-4 py-3 text-gray-600">{b.user.name}</td>}
                  <td className="px-4 py-3 text-gray-500">{b.borrowed_at}</td>
                  <td className="px-4 py-3 text-gray-500">{b.due_date}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${statusBadge[b.status]}`}>
                      {b.status}
                    </span>
                  </td>
                  {isLibrarian && (
                    <td className="px-4 py-3">
                      {b.status !== 'returned' && (
                        <Button
                          variant="ghost"
                          className="text-xs"
                          onClick={() => returnMutation.mutate(b.id)}
                          disabled={returnMutation.isPending}
                        >
                          Mark returned
                        </Button>
                      )}
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
