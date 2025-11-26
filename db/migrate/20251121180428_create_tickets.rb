class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :customer_support, foreign_key: { to_table: :users }
      t.string :status, default: 'open', null: false
      t.string :subject, null: false
      t.string :description
      t.timestamps
    end
  end
end
