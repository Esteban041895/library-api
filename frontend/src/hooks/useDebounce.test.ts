import { renderHook, act } from '@testing-library/react'
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import { useDebounce } from './useDebounce'

describe('useDebounce', () => {
  beforeEach(() => vi.useFakeTimers())
  afterEach(() => vi.useRealTimers())

  it('returns the initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('hello', 300))
    expect(result.current).toBe('hello')
  })

  it('does not update before the delay elapses', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 300),
      { initialProps: { value: 'hello' } }
    )

    rerender({ value: 'world' })
    act(() => vi.advanceTimersByTime(200))

    expect(result.current).toBe('hello')
  })

  it('updates after the delay elapses', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 300),
      { initialProps: { value: 'hello' } }
    )

    rerender({ value: 'world' })
    act(() => vi.advanceTimersByTime(300))

    expect(result.current).toBe('world')
  })

  it('cancels intermediate values and only emits the last one', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 300),
      { initialProps: { value: '' } }
    )

    rerender({ value: 'r' })
    act(() => vi.advanceTimersByTime(100))
    rerender({ value: 're' })
    act(() => vi.advanceTimersByTime(100))
    rerender({ value: 'rea' })
    act(() => vi.advanceTimersByTime(100))
    rerender({ value: 'reac' })
    act(() => vi.advanceTimersByTime(300))

    expect(result.current).toBe('reac')
  })
})
