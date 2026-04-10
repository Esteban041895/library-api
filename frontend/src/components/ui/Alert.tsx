type AlertType = 'error' | 'success' | 'warning'

interface AlertProps {
  type?: AlertType
  message: string | string[]
}

const styles: Record<AlertType, string> = {
  error: 'bg-red-50 border-red-200 text-red-700',
  success: 'bg-green-50 border-green-200 text-green-700',
  warning: 'bg-yellow-50 border-yellow-200 text-yellow-700',
}

export function Alert({ type = 'error', message }: AlertProps) {
  const messages = Array.isArray(message) ? message : [message]
  return (
    <div className={`border rounded-lg px-4 py-3 text-sm ${styles[type]}`}>
      {messages.length === 1 ? (
        <p>{messages[0]}</p>
      ) : (
        <ul className="list-disc list-inside space-y-1">
          {messages.map((m, i) => <li key={i}>{m}</li>)}
        </ul>
      )}
    </div>
  )
}
