class AddCancelledToSales < ActiveRecord::Migration[8.1]
  def change
    add_column :sales, :cancelled, :boolean, default: false, null: false
    add_column :sales, :cancelled_at, :datetime
  end
end
