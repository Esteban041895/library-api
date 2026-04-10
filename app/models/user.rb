class User < ApplicationRecord
  has_secure_password

  enum :role, { member: 0, librarian: 1 }

  has_many :borrowings, dependent: :destroy
  has_many :borrowed_books, through: :borrowings, source: :book

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true

  before_save { self.email = email.downcase }
end
