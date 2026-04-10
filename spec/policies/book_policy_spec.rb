require 'rails_helper'

RSpec.describe BookPolicy, type: :policy do
  let(:librarian) { build(:user, :librarian) }
  let(:member) { build(:user, :member) }
  let(:book) { build(:book) }

  describe "index?" do
    it "allows librarian" do
      expect(described_class.new(librarian, book).index?).to be true
    end

    it "allows member" do
      expect(described_class.new(member, book).index?).to be true
    end
  end

  describe "show?" do
    it "allows librarian" do
      expect(described_class.new(librarian, book).show?).to be true
    end

    it "allows member" do
      expect(described_class.new(member, book).show?).to be true
    end
  end

  describe "create?" do
    it "allows librarian" do
      expect(described_class.new(librarian, book).create?).to be true
    end

    it "denies member" do
      expect(described_class.new(member, book).create?).to be false
    end
  end

  describe "update?" do
    it "allows librarian" do
      expect(described_class.new(librarian, book).update?).to be true
    end

    it "denies member" do
      expect(described_class.new(member, book).update?).to be false
    end
  end

  describe "destroy?" do
    it "allows librarian" do
      expect(described_class.new(librarian, book).destroy?).to be true
    end

    it "denies member" do
      expect(described_class.new(member, book).destroy?).to be false
    end
  end

  describe "Scope" do
    it "returns all books for any authenticated user" do
      create(:book)
      scope = BookPolicy::Scope.new(member, Book).resolve
      expect(scope).to eq(Book.all)
    end
  end
end
