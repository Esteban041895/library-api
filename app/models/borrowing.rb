class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validate :book_must_be_available, on: :create
  validate :no_active_borrowing_for_same_book, on: :create

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { active.where("due_date < ?", Date.today) }
  scope :due_today, -> { active.where(due_date: Date.today) }

  def overdue?
    returned_at.nil? && due_date < Date.today
  end

  def returned?
    returned_at.present?
  end

  private

  def book_must_be_available
    return unless book

    errors.add(:book, "has no available copies") unless book.available?
  end

  def no_active_borrowing_for_same_book
    return unless book && user

    if Borrowing.active.exists?(user: user, book: book)
      errors.add(:book, "is already borrowed by this member")
    end
  end
end
