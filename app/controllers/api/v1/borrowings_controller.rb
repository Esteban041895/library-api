module Api
  module V1
    class BorrowingsController < ApplicationController
      include Authenticatable

      def create
        book = Book.find(params[:borrowing][:book_id])
        borrowing = Borrowing.new(
          user: current_user,
          book: book,
          borrowed_at: Date.today,
          due_date: 2.weeks.from_now.to_date
        )
        authorize borrowing

        Book.transaction do
          book.lock!
          if borrowing.save
            render json: borrowing_json(borrowing), status: :created
          else
            render json: { errors: borrowing.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      def return
        borrowing = Borrowing.find(params[:id])
        authorize borrowing, :return?

        if borrowing.returned?
          render json: { error: "Book already returned" }, status: :unprocessable_entity
          return
        end

        borrowing.update!(returned_at: Date.today)
        render json: borrowing_json(borrowing)
      end

      private

      def borrowing_json(borrowing)
        {
          id: borrowing.id,
          book: {
            id: borrowing.book.id,
            title: borrowing.book.title,
            author: borrowing.book.author
          },
          user: {
            id: borrowing.user.id,
            name: borrowing.user.name,
            email: borrowing.user.email
          },
          borrowed_at: borrowing.borrowed_at,
          due_date: borrowing.due_date,
          returned_at: borrowing.returned_at,
          overdue: borrowing.overdue?,
          status: borrowing_status(borrowing)
        }
      end

      def borrowing_status(borrowing)
        return "returned" if borrowing.returned?
        return "overdue" if borrowing.overdue?

        "active"
      end
    end
  end
end
