require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
    it { should have_many(:borrowers).through(:borrowings).source(:user) }
  end

  describe 'validations' do
    subject { build(:book) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:isbn) }
    it { should validate_numericality_of(:total_copies).only_integer.is_greater_than_or_equal_to(0) }

    it 'validates uniqueness of isbn' do
      create(:book, isbn: 'ABC-123')
      duplicate = build(:book, isbn: 'ABC-123')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:isbn]).to be_present
    end
  end

  describe '.search' do
    let!(:ruby_book) { create(:book, title: 'Ruby on Rails Guide', author: 'DHH', genre: 'Technology') }
    let!(:fiction_book) { create(:book, title: 'Great Novel', author: 'Jane Doe', genre: 'Fiction') }

    it 'returns all books when query is blank' do
      expect(Book.search('')).to include(ruby_book, fiction_book)
    end

    it 'searches by title (case-insensitive)' do
      expect(Book.search('ruby')).to include(ruby_book)
      expect(Book.search('ruby')).not_to include(fiction_book)
    end

    it 'searches by author (case-insensitive)' do
      expect(Book.search('jane')).to include(fiction_book)
      expect(Book.search('jane')).not_to include(ruby_book)
    end

    it 'searches by genre (case-insensitive)' do
      expect(Book.search('fiction')).to include(fiction_book)
      expect(Book.search('fiction')).not_to include(ruby_book)
    end
  end

  describe '#available_copies' do
    let(:book) { create(:book, total_copies: 3) }

    it 'returns total_copies when no active borrowings' do
      expect(book.available_copies).to eq(3)
    end

    it 'decrements for each active borrowing' do
      create(:borrowing, book: book)
      expect(book.available_copies).to eq(2)
    end

    it 'does not decrement for returned borrowings' do
      create(:borrowing, :returned, book: book)
      expect(book.available_copies).to eq(3)
    end
  end

  describe '#available?' do
    it 'returns true when copies are available' do
      book = create(:book, total_copies: 1)
      expect(book).to be_available
    end

    it 'returns false when all copies are borrowed' do
      book = create(:book, total_copies: 1)
      create(:borrowing, book: book)
      expect(book).not_to be_available
    end
  end
end
