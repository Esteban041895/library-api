require 'rails_helper'

RSpec.describe "Api::V1::Borrowings", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:other_member) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 2) }

  describe "GET /api/v1/borrowings" do
    let!(:member_borrowing) { create(:borrowing, user: member, book: book) }
    let!(:other_borrowing) { create(:borrowing, user: other_member, book: create(:book)) }

    it "returns all borrowings for librarian" do
      get "/api/v1/borrowings", headers: auth_headers(librarian)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
    end

    it "returns only own borrowings for member" do
      get "/api/v1/borrowings", headers: auth_headers(member)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body.first["user"]["id"]).to eq(member.id)
    end

    it "returns 401 for unauthenticated request" do
      get "/api/v1/borrowings"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/borrowings" do
    context "as member" do
      it "borrows an available book" do
        post "/api/v1/borrowings", params: { borrowing: { book_id: book.id } }, headers: auth_headers(member)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["book"]["id"]).to eq(book.id)
        expect(body["status"]).to eq("active")
        expect(body["due_date"]).to eq(2.weeks.from_now.to_date.to_s)
      end

      it "cannot borrow the same book twice" do
        create(:borrowing, user: member, book: book)
        post "/api/v1/borrowings", params: { borrowing: { book_id: book.id } }, headers: auth_headers(member)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include(a_string_matching(/already borrowed/))
      end

      it "cannot borrow when no copies available" do
        create(:borrowing, book: book)
        create(:borrowing, book: book)
        post "/api/v1/borrowings", params: { borrowing: { book_id: book.id } }, headers: auth_headers(member)
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include(a_string_matching(/no available copies/))
      end
    end

    context "as librarian" do
      it "returns 403" do
        post "/api/v1/borrowings", params: { borrowing: { book_id: book.id } }, headers: auth_headers(librarian)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/v1/borrowings/:id/return" do
    let!(:borrowing) { create(:borrowing, user: member, book: book) }

    context "as librarian" do
      it "marks the book as returned" do
        patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers(librarian)
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["returned_at"]).to eq(Date.today.to_s)
        expect(body["status"]).to eq("returned")
      end

      it "returns 422 if already returned" do
        borrowing.update!(returned_at: Date.today)
        patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers(librarian)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as member" do
      it "returns 403" do
        patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers(member)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
