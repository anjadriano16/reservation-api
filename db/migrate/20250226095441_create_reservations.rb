class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.references :guest, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :nights
      t.integer :adults
      t.integer :children
      t.integer :infants
      t.string :status
      t.string :currency
      t.decimal :payout_price
      t.decimal :security_price
      t.decimal :total_price
      t.integer :guest_id_from_payload

      t.timestamps
    end
  end
end
