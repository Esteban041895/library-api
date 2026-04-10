interface SearchBarProps {
  value: string
  onChange: (query: string) => void
}

export function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <input
      type="search"
      placeholder="Search by title, author, or genre…"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="w-full px-4 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
    />
  )
}
