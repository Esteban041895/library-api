puts "Seeding database..."

# Demo credentials
librarian = User.find_or_create_by!(email: "librarian@library.com") do |u|
  u.name = "Alice Librarian"
  u.password = "password123"
  u.role = :librarian
end

member1 = User.find_or_create_by!(email: "member1@library.com") do |u|
  u.name = "Bob Member"
  u.password = "password123"
  u.role = :member
end

member2 = User.find_or_create_by!(email: "member2@library.com") do |u|
  u.name = "Carol Reader"
  u.password = "password123"
  u.role = :member
end

puts "Created #{User.count} users"

# Books
books_data = [
  { title: "Clean Code", author: "Robert C. Martin", genre: "Technology", isbn: "978-0132350884", total_copies: 3 },
  { title: "The Pragmatic Programmer", author: "David Thomas", genre: "Technology", isbn: "978-0135957059", total_copies: 2 },
  { title: "Design Patterns", author: "Gang of Four", genre: "Technology", isbn: "978-0201633610", total_copies: 2 },
  { title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Fiction", isbn: "978-0743273565", total_copies: 4 },
  { title: "To Kill a Mockingbird", author: "Harper Lee", genre: "Fiction", isbn: "978-0061935466", total_copies: 3 },
  { title: "1984", author: "George Orwell", genre: "Dystopian", isbn: "978-0451524935", total_copies: 5 },
  { title: "Brave New World", author: "Aldous Huxley", genre: "Dystopian", isbn: "978-0060850524", total_copies: 2 },
  { title: "Sapiens", author: "Yuval Noah Harari", genre: "Non-Fiction", isbn: "978-0062316097", total_copies: 3 },
  { title: "Educated", author: "Tara Westover", genre: "Memoir", isbn: "978-0399590504", total_copies: 2 },
  { title: "The Alchemist", author: "Paulo Coelho", genre: "Fiction", isbn: "978-0062315007", total_copies: 4 },
  { title: "Atomic Habits", author: "James Clear", genre: "Self-Help", isbn: "978-0735211292", total_copies: 3 },
  { title: "Dune", author: "Frank Herbert", genre: "Science Fiction", isbn: "978-0441013593", total_copies: 2 },
  { title: "The Hitchhiker's Guide to the Galaxy", author: "Douglas Adams", genre: "Science Fiction", isbn: "978-0345391803", total_copies: 3 },
  { title: "Pride and Prejudice", author: "Jane Austen", genre: "Classic", isbn: "978-0141439518", total_copies: 4 },
  { title: "The Lord of the Rings", author: "J.R.R. Tolkien", genre: "Fantasy", isbn: "978-0544003415", total_copies: 2 }
]

books = books_data.map do |attrs|
  Book.find_or_create_by!(isbn: attrs[:isbn]) { |b| b.assign_attributes(attrs) }
end

puts "Created #{Book.count} books"

# Borrowings — idempotent: only create if user has no active borrowing for that book
def borrow_if_new(user, book, borrowed_at:, due_date:)
  return if Borrowing.active.exists?(user: user, book: book)

  Borrowing.create!(user: user, book: book, borrowed_at: borrowed_at, due_date: due_date)
end

# member1: two active borrowings
borrow_if_new(member1, books[0], borrowed_at: 5.days.ago, due_date: 9.days.from_now)
borrow_if_new(member1, books[3], borrowed_at: 3.days.ago, due_date: 11.days.from_now)

# member2: one active + one overdue
borrow_if_new(member2, books[6], borrowed_at: 10.days.ago, due_date: 4.days.from_now)
borrow_if_new(member2, books[1], borrowed_at: 25.days.ago, due_date: 11.days.ago)

puts "Borrowings: #{Borrowing.count} total (including overdue)"

puts "\nDone! Demo credentials:"
puts "  Librarian: librarian@library.com / password123"
puts "  Member 1:  member1@library.com / password123"
puts "  Member 2:  member2@library.com / password123"
