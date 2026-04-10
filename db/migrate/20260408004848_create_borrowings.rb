class CreateBorrowings < ActiveRecord::Migration[7.2]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.date :borrowed_at, null: false
      t.date :due_date, null: false
      t.date :returned_at

      t.timestamps
    end
    add_index :borrowings, [:user_id, :book_id],
              unique: true,
              where: "returned_at IS NULL",
              name: "index_borrowings_on_user_book_active"
  end
end
