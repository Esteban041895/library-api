require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
    it { should have_many(:borrowed_books).through(:borrowings).source(:book) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should have_secure_password }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, librarian: 1) }
  end

  describe '#member?' do
    it 'returns true for member role' do
      expect(build(:user, :member)).to be_member
    end
  end

  describe '#librarian?' do
    it 'returns true for librarian role' do
      expect(build(:user, :librarian)).to be_librarian
    end
  end

  describe 'email normalization' do
    it 'downcases email before saving' do
      user = create(:user, email: 'Test@EXAMPLE.COM')
      expect(user.reload.email).to eq('test@example.com')
    end
  end
end
