class BorrowingPolicy < ApplicationPolicy
  def index? = true

  def create? = user.member?

  # :return action (marking as returned)
  def return? = user.librarian?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.librarian?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
