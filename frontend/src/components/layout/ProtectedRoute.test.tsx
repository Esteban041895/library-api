import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { vi, describe, it, expect } from 'vitest'
import { ProtectedRoute } from './ProtectedRoute'
import { useAuth } from '../../context/AuthContext'

vi.mock('../../context/AuthContext')

const mockUseAuth = vi.mocked(useAuth)

function renderWithRouter(ui: React.ReactNode, { initialPath = '/' } = {}) {
  return render(
    <MemoryRouter initialEntries={[initialPath]}>
      <Routes>
        <Route path="/login" element={<div>Login page</div>} />
        <Route
          path="/"
          element={<ProtectedRoute>{ui}</ProtectedRoute>}
        />
      </Routes>
    </MemoryRouter>
  )
}

describe('ProtectedRoute', () => {
  it('renders children when user is authenticated', () => {
    mockUseAuth.mockReturnValue({
      user: { id: 1, name: 'Alice', email: 'alice@example.com', role: 'member' },
      isLibrarian: false,
      login: vi.fn(),
      register: vi.fn(),
      logout: vi.fn(),
    })

    renderWithRouter(<div>Protected content</div>)

    expect(screen.getByText('Protected content')).toBeInTheDocument()
  })

  it('redirects to /login when user is null', () => {
    mockUseAuth.mockReturnValue({
      user: null,
      isLibrarian: false,
      login: vi.fn(),
      register: vi.fn(),
      logout: vi.fn(),
    })

    renderWithRouter(<div>Protected content</div>)

    expect(screen.queryByText('Protected content')).not.toBeInTheDocument()
    expect(screen.getByText('Login page')).toBeInTheDocument()
  })
})
