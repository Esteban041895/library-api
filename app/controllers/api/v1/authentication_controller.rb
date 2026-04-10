module Api
  module V1
    class AuthenticationController < ApplicationController
      include Authenticatable

      skip_before_action :authenticate_request, only: [ :register, :login ]

      def register
        user = User.new(register_params)
        if user.save
          token = issue_token(user)
          render json: { token: token, user: user_payload(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: login_params[:email]&.downcase)
        if user&.authenticate(login_params[:password])
          token = issue_token(user)
          render json: { token: token, user: user_payload(user) }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def logout
        current_user.increment!(:token_version)
        head :no_content
      end

      private

      def issue_token(user)
        JwtService.encode(user_id: user.id, token_version: user.token_version)
      end

      def register_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def login_params
        params.require(:user).permit(:email, :password)
      end

      def user_payload(user)
        { id: user.id, name: user.name, email: user.email, role: user.role }
      end
    end
  end
end
