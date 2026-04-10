import { useQuery } from '@tanstack/react-query'
import { api } from '../lib/api'
import { useAuth } from '../context/AuthContext'
import type { LibrarianDashboard, MemberDashboard } from '../lib/types'

function StatCard({ label, value, accent }: { label: string; value: number; accent?: boolean }) {
  return (
    <div className={`rounded-xl border p-5 ${accent ? 'border-red-200 bg-red-50' : 'border-gray-200 bg-white'}`}>
      <p className="text-sm text-gray-500">{label}</p>
      <p className={`text-3xl font-semibold mt-1 ${accent ? 'text-red-600' : 'text-gray-900'}`}>{value}</p>
    </div>
  )
}

function LibrarianView({ data }: { data: LibrarianDashboard }) {
  return (
    <div className="flex flex-col gap-8">
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard label="Total books" value={data.total_books} />
        <StatCard label="Currently borrowed" value={data.total_borrowed} />
        <StatCard label="Due today" value={data.books_due_today} accent={data.books_due_today > 0} />
        <StatCard label="Overdue members" value={data.overdue_members.length} accent={data.overdue_members.length > 0} />
      </div>

      {data.overdue_members.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Overdue members</h2>
          <div className="flex flex-col gap-3">
            {data.overdue_members.map(({ user, overdue_books }) => (
              <div key={user.id} className="bg-white rounded-xl border border-red-200 p-4">
                <p className="font-medium text-gray-900">{user.name}</p>
                <p className="text-xs text-gray-500 mb-3">{user.email}</p>
                <div className="flex flex-col gap-1">
                  {overdue_books.map((b) => (
                    <div key={b.borrowing_id} className="flex justify-between text-sm">
                      <span className="text-gray-700">{b.book.title}</span>
                      <span className="text-red-600 font-medium">{b.days_overdue}d overdue</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

function MemberView({ data }: { data: MemberDashboard }) {
  return (
    <div className="flex flex-col gap-8">
      <div className="grid grid-cols-2 gap-4">
        <StatCard label="Active borrowings" value={data.borrowed_books.length} />
        <StatCard label="Overdue" value={data.overdue_books.length} accent={data.overdue_books.length > 0} />
      </div>

      {data.overdue_books.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold text-red-700 mb-3">Overdue books</h2>
          <div className="flex flex-col gap-2">
            {data.overdue_books.map((b) => (
              <div key={b.id} className="flex justify-between items-center bg-red-50 border border-red-200 rounded-lg px-4 py-3 text-sm">
                <span className="font-medium text-gray-900">{b.book.title}</span>
                <span className="text-red-600">Due {b.due_date}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {data.borrowed_books.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Currently borrowed</h2>
          <div className="flex flex-col gap-2">
            {data.borrowed_books.map((b) => (
              <div key={b.id} className="flex justify-between items-center bg-white border border-gray-200 rounded-lg px-4 py-3 text-sm">
                <span className="font-medium text-gray-900">{b.book.title}</span>
                <span className="text-gray-500">Due {b.due_date}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {data.borrowed_books.length === 0 && data.overdue_books.length === 0 && (
        <p className="text-gray-400 text-sm">You have no active borrowings.</p>
      )}
    </div>
  )
}

export function DashboardPage() {
  const { user, isLibrarian } = useAuth()

  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: async () => {
      const { data } = await api.get<LibrarianDashboard | MemberDashboard>('/dashboard')
      return data
    },
  })

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 text-sm mt-1">Welcome back, {user?.name}</p>
      </div>

      {isLoading ? (
        <p className="text-gray-400 text-sm">Loading…</p>
      ) : data ? (
        isLibrarian
          ? <LibrarianView data={data as LibrarianDashboard} />
          : <MemberView data={data as MemberDashboard} />
      ) : null}
    </div>
  )
}
