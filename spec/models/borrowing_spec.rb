require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it { should validate_presence_of(:borrowed_at) }
    it { should validate_presence_of(:due_date) }
  end

  describe 'custom validations' do
    context 'when book has no available copies' do
      it 'is invalid' do
        book = create(:book, total_copies: 1)
        create(:borrowing, book: book)
        new_borrowing = build(:borrowing, book: book)
        expect(new_borrowing).not_to be_valid
        expect(new_borrowing.errors[:book]).to include("has no available copies")
      end
    end

    context 'when member already has an active borrowing for the same book' do
      it 'is invalid' do
        user = create(:user)
        book = create(:book, total_copies: 5)
        create(:borrowing, user: user, book: book)
        duplicate = build(:borrowing, user: user, book: book)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:book]).to include("is already borrowed by this member")
      end
    end

    context 'when member returned the book and wants to borrow again' do
      it 'is valid' do
        user = create(:user)
        book = create(:book, total_copies: 5)
        create(:borrowing, :returned, user: user, book: book)
        new_borrowing = build(:borrowing, user: user, book: book)
        expect(new_borrowing).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:active_borrowing) { create(:borrowing) }
    let!(:returned_borrowing) { create(:borrowing, :returned) }
    let!(:overdue_borrowing) { create(:borrowing, :overdue) }
    let!(:due_today_borrowing) { create(:borrowing, :due_today) }

    describe '.active' do
      it 'returns only unreturned borrowings' do
        expect(Borrowing.active).to include(active_borrowing, overdue_borrowing, due_today_borrowing)
        expect(Borrowing.active).not_to include(returned_borrowing)
      end
    end

    describe '.returned' do
      it 'returns only returned borrowings' do
        expect(Borrowing.returned).to include(returned_borrowing)
        expect(Borrowing.returned).not_to include(active_borrowing)
      end
    end

    describe '.overdue' do
      it 'returns active borrowings past due date' do
        expect(Borrowing.overdue).to include(overdue_borrowing)
        expect(Borrowing.overdue).not_to include(active_borrowing, returned_borrowing, due_today_borrowing)
      end
    end

    describe '.due_today' do
      it 'returns active borrowings due today' do
        expect(Borrowing.due_today).to include(due_today_borrowing)
        expect(Borrowing.due_today).not_to include(active_borrowing, overdue_borrowing)
      end
    end
  end

  describe '#overdue?' do
    it 'returns true when past due and not returned' do
      expect(build(:borrowing, :overdue)).to be_overdue
    end

    it 'returns false when returned even if past due' do
      borrowing = build(:borrowing, :overdue, returned_at: Date.today)
      expect(borrowing).not_to be_overdue
    end
  end

  describe '#returned?' do
    it 'returns true when returned_at is set' do
      expect(build(:borrowing, :returned)).to be_returned
    end

    it 'returns false when not returned' do
      expect(build(:borrowing)).not_to be_returned
    end
  end
end
