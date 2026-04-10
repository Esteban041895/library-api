require 'rails_helper'

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 5) }

  describe "GET /api/v1/dashboard" do
    it "returns 401 for unauthenticated request" do
      get "/api/v1/dashboard"
      expect(response).to have_http_status(:unauthorized)
    end

    context "as librarian" do
      before do
        create(:borrowing, book: book)
        create(:borrowing, :due_today, book: book)
        create(:borrowing, :overdue, user: member, book: book)
      end

      it "returns librarian dashboard stats" do
        get "/api/v1/dashboard", headers: auth_headers(librarian)
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)

        expect(body["total_books"]).to eq(1)
        expect(body["total_borrowed"]).to eq(3)
        expect(body["books_due_today"]).to eq(1)
        expect(body["overdue_members"]).to be_an(Array)
        expect(body["overdue_members"].length).to eq(1)
        expect(body["overdue_members"].first["user"]["id"]).to eq(member.id)
      end

      it "returns an empty overdue_members list when none are overdue" do
        Borrowing.destroy_all
        get "/api/v1/dashboard", headers: auth_headers(librarian)
        body = JSON.parse(response.body)
        expect(body["overdue_members"]).to eq([])
      end
    end
  end
end
