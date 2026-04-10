module Api
  module V1
    class AuthenticationController < ApplicationController
      def register
        user = User.new(register_params)
        if user.save
          token = JwtService.encode(user_id: user.id)
          render json: { token: token, user: user_payload(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def register_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
      end

      def user_payload(user)
        { id: user.id, name: user.name, email: user.email, role: user.role }
      end
    end
  end
end
