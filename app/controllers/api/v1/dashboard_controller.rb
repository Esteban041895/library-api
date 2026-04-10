module Api
  module V1
    class DashboardController < ApplicationController
      include Authenticatable

      def index
        render json: librarian_dashboard
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

      def overdue_book_json(borrowing)
        {
          borrowing_id: borrowing.id,
          book: { id: borrowing.book.id, title: borrowing.book.title },
          due_date: borrowing.due_date,
          days_overdue: (Date.today - borrowing.due_date).to_i
        }
      end
    end
  end
end
