class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.string :customer_email, null: false
      t.string :customer_name, null: false

      t.timestamps
    end
  end
end

