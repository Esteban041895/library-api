import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'

export function Navbar() {
  const { user, isLibrarian, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <nav className="bg-white border-b border-gray-200 px-6 py-3 flex items-center justify-between">
      <div className="flex items-center gap-6">
        <Link to="/" className="text-lg font-semibold text-indigo-600">
          📚 Library
        </Link>
        <Link to="/books" className="text-sm text-gray-600 hover:text-gray-900">
          Books
        </Link>
        <Link to="/borrowings" className="text-sm text-gray-600 hover:text-gray-900">
          Borrowings
        </Link>
      </div>

      <div className="flex items-center gap-3">
        <span className="text-sm text-gray-500">{user?.name}</span>
        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
          isLibrarian
            ? 'bg-indigo-100 text-indigo-700'
            : 'bg-green-100 text-green-700'
        }`}>
          {user?.role}
        </span>
        <button
          onClick={handleLogout}
          className="text-sm text-gray-500 hover:text-red-600 transition-colors"
        >
          Logout
        </button>
      </div>
    </nav>
  )
}
