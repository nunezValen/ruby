class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nombre, :string
    add_column :users, :apellido, :string
    add_column :users, :rol, :string
  end
end
