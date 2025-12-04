class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.string :author
      t.decimal :unit_price, precision: 10, scale: 2
      t.integer :stock
      t.integer :media_type
      t.integer :state
      t.date :received_on
      t.datetime :retired_at
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
