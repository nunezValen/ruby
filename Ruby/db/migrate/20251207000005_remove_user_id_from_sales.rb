class RemoveUserIdFromSales < ActiveRecord::Migration[8.1]
  def up
    # Eliminar el índice primero
    if index_exists?(:sales, :user_id)
      remove_index :sales, :user_id
    end
    
    # Eliminar la columna user_id
    if column_exists?(:sales, :user_id)
      remove_column :sales, :user_id, :integer
    end
  end

  def down
    add_column :sales, :user_id, :integer
    add_index :sales, :user_id
  end
end
