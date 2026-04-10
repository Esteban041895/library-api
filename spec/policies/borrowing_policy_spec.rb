require 'rails_helper'

RSpec.describe BorrowingPolicy, type: :policy do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:other_member) { create(:user, :member) }
  let(:borrowing) { create(:borrowing, user: member) }

  describe "index?" do
    it "allows librarian" do
      expect(described_class.new(librarian, borrowing).index?).to be true
    end

    it "allows member" do
      expect(described_class.new(member, borrowing).index?).to be true
    end
  end

  describe "create?" do
    it "allows member" do
      expect(described_class.new(member, borrowing).create?).to be true
    end

    it "denies librarian" do
      expect(described_class.new(librarian, borrowing).create?).to be false
    end
  end

  describe "return?" do
    it "allows librarian" do
      expect(described_class.new(librarian, borrowing).return?).to be true
    end

    it "denies member" do
      expect(described_class.new(member, borrowing).return?).to be false
    end
  end

  describe "Scope" do
    let!(:member_borrowing) { create(:borrowing, user: member) }
    let!(:other_borrowing) { create(:borrowing, user: other_member) }

    it "returns all borrowings for librarian" do
      scope = BorrowingPolicy::Scope.new(librarian, Borrowing).resolve
      expect(scope).to include(member_borrowing, other_borrowing)
    end

    it "returns only own borrowings for member" do
      scope = BorrowingPolicy::Scope.new(member, Borrowing).resolve
      expect(scope).to include(member_borrowing)
      expect(scope).not_to include(other_borrowing)
    end
  end
end
