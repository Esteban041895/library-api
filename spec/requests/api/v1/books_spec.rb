require 'rails_helper'

RSpec.describe "Api::V1::Books", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let!(:book) { create(:book, title: "Clean Code", author: "Robert Martin", genre: "Technology") }

  describe "GET /api/v1/books" do
    it "returns all books for authenticated user" do
      get "/api/v1/books", headers: auth_headers(member)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
    end

    it "returns 401 for unauthenticated request" do
      get "/api/v1/books"
      expect(response).to have_http_status(:unauthorized)
    end

    context "with search" do
      let!(:other_book) { create(:book, title: "The Pragmatic Programmer", author: "Hunt", genre: "Technology") }

      it "filters by title" do
        get "/api/v1/books", params: { search: "clean" }, headers: auth_headers(member)
        body = JSON.parse(response.body)
        titles = body.map { |b| b["title"] }
        expect(titles).to include("Clean Code")
        expect(titles).not_to include("The Pragmatic Programmer")
      end

      it "filters by author" do
        get "/api/v1/books", params: { search: "hunt" }, headers: auth_headers(member)
        body = JSON.parse(response.body)
        expect(body.first["title"]).to eq("The Pragmatic Programmer")
      end

      it "returns all when search is blank" do
        get "/api/v1/books", params: { search: "" }, headers: auth_headers(member)
        body = JSON.parse(response.body)
        expect(body.length).to eq(2)
      end
    end
  end

  describe "GET /api/v1/books/:id" do
    it "returns the book" do
      get "/api/v1/books/#{book.id}", headers: auth_headers(member)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Clean Code")
      expect(body["available_copies"]).to eq(book.total_copies)
    end

    it "returns 404 for non-existent book" do
      get "/api/v1/books/999999", headers: auth_headers(member)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/books" do
    let(:valid_params) { { book: { title: "New Book", author: "Author", genre: "Fiction", isbn: "ISBN-001", total_copies: 5 } } }

    context "as librarian" do
      it "creates a book" do
        post "/api/v1/books", params: valid_params, headers: auth_headers(librarian)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["title"]).to eq("New Book")
      end
    end

    context "as member" do
      it "returns 403" do
        post "/api/v1/books", params: valid_params, headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with invalid params" do
      it "returns 422" do
        post "/api/v1/books", params: { book: { title: "" } }, headers: auth_headers(librarian)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to be_present
      end
    end
  end
end
