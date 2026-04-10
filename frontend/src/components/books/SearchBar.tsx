import { useState, useEffect } from 'react'

interface SearchBarProps {
  onSearch: (query: string) => void
}

export function SearchBar({ onSearch }: SearchBarProps) {
  const [value, setValue] = useState('')

  useEffect(() => {
    const timer = setTimeout(() => onSearch(value), 300)
    return () => clearTimeout(timer)
  }, [value, onSearch])

  return (
    <input
      type="search"
      placeholder="Search by title, author, or genre…"
      value={value}
      onChange={(e) => setValue(e.target.value)}
      className="w-full px-4 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
    />
  )
}
