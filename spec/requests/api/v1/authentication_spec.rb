require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  describe "POST /api/v1/register" do
    let(:valid_params) do
      {
        user: {
          name: "Alice",
          email: "alice@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    context "with valid params" do
      it "creates a user and returns a token" do
        post "/api/v1/register", params: valid_params
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
        expect(body["user"]["email"]).to eq("alice@example.com")
        expect(body["user"]["role"]).to eq("member")
      end

      it "defaults role to member" do
        post "/api/v1/register", params: valid_params
        expect(User.last.role).to eq("member")
      end
    end

    context "with duplicate email" do
      before { create(:user, email: "alice@example.com") }

      it "returns 422 with errors" do
        post "/api/v1/register", params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to be_present
      end
    end

    context "with missing fields" do
      it "returns 422 when name is missing" do
        post "/api/v1/register", params: { user: { email: "a@b.com", password: "pass" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when email is missing" do
        post "/api/v1/register", params: { user: { name: "Alice", password: "pass" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/login" do
    let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns a token and user info" do
        post "/api/v1/login", params: { user: { email: "alice@example.com", password: "password123" } }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
        expect(body["user"]["email"]).to eq("alice@example.com")
      end
    end

    context "with wrong password" do
      it "returns 401" do
        post "/api/v1/login", params: { user: { email: "alice@example.com", password: "wrong" } }
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Invalid email or password")
      end
    end

    context "with non-existent email" do
      it "returns 401" do
        post "/api/v1/login", params: { user: { email: "nobody@example.com", password: "password123" } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/logout" do
    let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

    context "with a valid token" do
      it "returns 204 and invalidates the token" do
        delete "/api/v1/logout", headers: auth_headers(user)
        expect(response).to have_http_status(:no_content)
      end

      it "rejects the old token on subsequent requests" do
        old_headers = auth_headers(user)
        delete "/api/v1/logout", headers: old_headers

        get "/api/v1/books", headers: old_headers
        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Token has been revoked")
      end
    end

    context "without a token" do
      it "returns 401" do
        delete "/api/v1/logout"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
