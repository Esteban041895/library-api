import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '../lib/api'
import { Input } from '../components/ui/Input'
import { Button } from '../components/ui/Button'
import { Alert } from '../components/ui/Alert'
import type { Book, ApiError } from '../lib/types'
import axios from 'axios'

interface BookFormData {
  title: string
  author: string
  genre: string
  isbn: string
  total_copies: number
}

const empty: BookFormData = { title: '', author: '', genre: '', isbn: '', total_copies: 1 }

export function BookFormPage() {
  const { id } = useParams()
  const isEdit = !!id
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [form, setForm] = useState<BookFormData>(empty)
  const [errors, setErrors] = useState<string[]>([])

  const { data: book } = useQuery({
    queryKey: ['book', id],
    queryFn: async () => {
      const { data } = await api.get<Book>(`/books/${id}`)
      return data
    },
    enabled: isEdit,
  })

  useEffect(() => {
    if (book) {
      setForm({ title: book.title, author: book.author, genre: book.genre, isbn: book.isbn, total_copies: book.total_copies })
    }
  }, [book])

  const mutation = useMutation({
    mutationFn: (data: BookFormData) =>
      isEdit ? api.patch(`/books/${id}`, { book: data }) : api.post('/books', { book: data }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] })
      navigate('/books')
    },
    onError: (err: unknown) => {
      if (axios.isAxiosError(err)) {
        const data = err.response?.data as ApiError
        setErrors(data?.errors ?? [data?.error ?? 'Failed to save book'])
      }
    },
  })

  const set = (field: keyof BookFormData) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm((prev) => ({ ...prev, [field]: field === 'total_copies' ? Number(e.target.value) : e.target.value }))

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setErrors([])
    mutation.mutate(form)
  }

  return (
    <div className="max-w-lg">
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">
        {isEdit ? 'Edit book' : 'Add book'}
      </h1>

      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          {errors.length > 0 && <Alert message={errors} />}
          <Input label="Title" value={form.title} onChange={set('title')} required />
          <Input label="Author" value={form.author} onChange={set('author')} required />
          <Input label="Genre" value={form.genre} onChange={set('genre')} required />
          <Input label="ISBN" value={form.isbn} onChange={set('isbn')} required />
          <Input label="Total copies" type="number" min={0} value={form.total_copies} onChange={set('total_copies')} required />

          <div className="flex gap-3 mt-2">
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? 'Saving…' : isEdit ? 'Save changes' : 'Add book'}
            </Button>
            <Button type="button" variant="secondary" onClick={() => navigate('/books')}>
              Cancel
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
