import { renderHook, act, waitFor } from '@testing-library/react'
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import { AuthProvider, useAuth } from './AuthContext'
import { api } from '../lib/api'

vi.mock('../lib/api', () => ({
  api: {
    post: vi.fn(),
  },
}))

const mockPost = vi.mocked(api.post)

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <AuthProvider>{children}</AuthProvider>
)

const fakeUser = { id: 1, name: 'Alice', email: 'alice@example.com', role: 'member' as const }
const fakeToken = 'fake.jwt.token'

describe('AuthContext', () => {
  beforeEach(() => {
    localStorage.clear()
    vi.clearAllMocks()
  })

  afterEach(() => {
    localStorage.clear()
  })

  describe('initial state', () => {
    it('starts with null user when localStorage is empty', () => {
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.user).toBeNull()
    })

    it('restores user from localStorage on mount', () => {
      localStorage.setItem('user', JSON.stringify(fakeUser))
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.user).toEqual(fakeUser)
    })

    it('handles corrupted localStorage gracefully', () => {
      localStorage.setItem('user', 'not-json')
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.user).toBeNull()
    })
  })

  describe('isLibrarian', () => {
    it('is false when user is null', () => {
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.isLibrarian).toBe(false)
    })

    it('is false for member role', () => {
      localStorage.setItem('user', JSON.stringify(fakeUser))
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.isLibrarian).toBe(false)
    })

    it('is true for librarian role', () => {
      localStorage.setItem('user', JSON.stringify({ ...fakeUser, role: 'librarian' }))
      const { result } = renderHook(() => useAuth(), { wrapper })
      expect(result.current.isLibrarian).toBe(true)
    })
  })

  describe('login', () => {
    it('sets user state and persists to localStorage on success', async () => {
      mockPost.mockResolvedValueOnce({ data: { token: fakeToken, user: fakeUser } })

      const { result } = renderHook(() => useAuth(), { wrapper })

      await act(async () => {
        await result.current.login('alice@example.com', 'password123')
      })

      expect(result.current.user).toEqual(fakeUser)
      expect(localStorage.getItem('token')).toBe(fakeToken)
      expect(JSON.parse(localStorage.getItem('user')!)).toEqual(fakeUser)
    })

    it('posts to /login with correct payload', async () => {
      mockPost.mockResolvedValueOnce({ data: { token: fakeToken, user: fakeUser } })

      const { result } = renderHook(() => useAuth(), { wrapper })

      await act(async () => {
        await result.current.login('alice@example.com', 'password123')
      })

      expect(mockPost).toHaveBeenCalledWith('/login', {
        user: { email: 'alice@example.com', password: 'password123' },
      })
    })

    it('propagates errors from the API', async () => {
      mockPost.mockRejectedValueOnce(new Error('Invalid credentials'))

      const { result } = renderHook(() => useAuth(), { wrapper })

      await expect(
        act(async () => { await result.current.login('bad@example.com', 'wrong') })
      ).rejects.toThrow('Invalid credentials')

      expect(result.current.user).toBeNull()
    })
  })

  describe('register', () => {
    it('sets user state and persists to localStorage on success', async () => {
      mockPost.mockResolvedValueOnce({ data: { token: fakeToken, user: fakeUser } })

      const { result } = renderHook(() => useAuth(), { wrapper })

      await act(async () => {
        await result.current.register('Alice', 'alice@example.com', 'password123')
      })

      expect(result.current.user).toEqual(fakeUser)
      expect(localStorage.getItem('token')).toBe(fakeToken)
    })

    it('posts to /register with password_confirmation', async () => {
      mockPost.mockResolvedValueOnce({ data: { token: fakeToken, user: fakeUser } })

      const { result } = renderHook(() => useAuth(), { wrapper })

      await act(async () => {
        await result.current.register('Alice', 'alice@example.com', 'password123')
      })

      expect(mockPost).toHaveBeenCalledWith('/register', {
        user: {
          name: 'Alice',
          email: 'alice@example.com',
          password: 'password123',
          password_confirmation: 'password123',
        },
      })
    })
  })

  describe('logout', () => {
    it('clears user state and localStorage', async () => {
      localStorage.setItem('token', fakeToken)
      localStorage.setItem('user', JSON.stringify(fakeUser))

      const { result } = renderHook(() => useAuth(), { wrapper })

      act(() => result.current.logout())

      await waitFor(() => expect(result.current.user).toBeNull())
      expect(localStorage.getItem('token')).toBeNull()
      expect(localStorage.getItem('user')).toBeNull()
    })
  })

  describe('useAuth guard', () => {
    it('throws when called outside AuthProvider', () => {
      const spy = vi.spyOn(console, 'error').mockImplementation(() => {})
      expect(() => renderHook(() => useAuth())).toThrow('useAuth must be used inside AuthProvider')
      spy.mockRestore()
    })
  })
})
