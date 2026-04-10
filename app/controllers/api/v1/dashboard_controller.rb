module Api
  module V1
    class DashboardController < ApplicationController
      include Authenticatable

      def index
        if current_user.librarian?
          render json: librarian_dashboard
        else
          render json: member_dashboard
        end
      end

      private

      def librarian_dashboard
        overdue_members = Borrowing.overdue
          .includes(:user, :book)
          .group_by(&:user)
          .map do |user, borrowings|
            {
              user: { id: user.id, name: user.name, email: user.email },
              overdue_books: borrowings.map { |b| overdue_book_json(b) }
            }
          end

        {
          total_books: Book.count,
          total_borrowed: Borrowing.active.count,
          books_due_today: Borrowing.due_today.count,
          overdue_members: overdue_members
        }
      end

      def member_dashboard
        borrowings = Borrowing.where(user: current_user).includes(:book).order(due_date: :asc)

        {
          borrowed_books: borrowings.active.where("due_date >= ?", Date.today).map { |b| member_borrowing_json(b) },
          overdue_books: borrowings.overdue.map { |b| member_borrowing_json(b) }
        }
      end

      def member_borrowing_json(borrowing)
        {
          id: borrowing.id,
          book: { id: borrowing.book.id, title: borrowing.book.title, author: borrowing.book.author },
          borrowed_at: borrowing.borrowed_at,
          due_date: borrowing.due_date,
          overdue: borrowing.overdue?,
          status: borrowing_status(borrowing)
        }
      end

      def overdue_book_json(borrowing)
        {
          borrowing_id: borrowing.id,
          book: { id: borrowing.book.id, title: borrowing.book.title },
          due_date: borrowing.due_date,
          days_overdue: (Date.today - borrowing.due_date).to_i
        }
      end

      def borrowing_status(borrowing)
        return "overdue" if borrowing.overdue?

        "active"
      end
    end
  end
end
