import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import MockAdapter from 'axios-mock-adapter'
import { api } from './api'

const mock = new MockAdapter(api)

const fakeToken = 'fake.jwt.token'

describe('api', () => {
  beforeEach(() => {
    localStorage.clear()
    mock.reset()
  })

  afterEach(() => {
    localStorage.clear()
  })

  describe('request interceptor', () => {
    it('attaches Authorization header when token is in localStorage', async () => {
      localStorage.setItem('token', fakeToken)
      mock.onGet('/books').reply(200, [])

      await api.get('/books')

      expect(mock.history.get[0].headers?.Authorization).toBe(`Bearer ${fakeToken}`)
    })

    it('sends no Authorization header when no token is stored', async () => {
      mock.onGet('/books').reply(200, [])

      await api.get('/books')

      expect(mock.history.get[0].headers?.Authorization).toBeUndefined()
    })
  })

  describe('response interceptor', () => {
    it('clears localStorage and redirects to /login on 401', async () => {
      localStorage.setItem('token', fakeToken)
      localStorage.setItem('user', JSON.stringify({ id: 1 }))

      const assign = vi.fn()
      Object.defineProperty(window, 'location', {
        value: { href: '/', set href(v: string) { assign(v) } },
        writable: true,
      })

      mock.onGet('/books').reply(401)

      await api.get('/books').catch(() => {})

      expect(localStorage.getItem('token')).toBeNull()
      expect(localStorage.getItem('user')).toBeNull()
      expect(assign).toHaveBeenCalledWith('/login')
    })

    it('does not clear localStorage for non-401 errors', async () => {
      localStorage.setItem('token', fakeToken)
      mock.onGet('/books').reply(500)

      await api.get('/books').catch(() => {})

      expect(localStorage.getItem('token')).toBe(fakeToken)
    })
  })
})
