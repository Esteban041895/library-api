module Api
  module V1
    class BooksController < ApplicationController
      include Authenticatable

      def index
        books = policy_scope(Book).search(params[:search])
        render json: books.map { |b| book_json(b) }
      end

      def show
        book = Book.find(params[:id])
        authorize book
        render json: book_json(book)
      end

      private

      def book_json(book)
        {
          id: book.id,
          title: book.title,
          author: book.author,
          genre: book.genre,
          isbn: book.isbn,
          total_copies: book.total_copies,
          available_copies: book.available_copies,
          created_at: book.created_at,
          updated_at: book.updated_at
        }
      end
    end
  end
end
