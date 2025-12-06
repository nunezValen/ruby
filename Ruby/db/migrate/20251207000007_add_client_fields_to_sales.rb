class AddClientFieldsToSales < ActiveRecord::Migration[8.1]
  def change
    add_column :sales, :client_name, :string
    add_column :sales, :client_email, :string
  end
end
