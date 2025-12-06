class AddEmployeeFieldsToSales < ActiveRecord::Migration[8.1]
  def change
    # Si la tabla ya tiene user_id, lo eliminamos (o lo mantenemos si prefieres)
    # Por ahora, agregamos las columnas employee_email y employee_name
    add_column :sales, :employee_email, :string, null: false, default: ""
    add_column :sales, :employee_name, :string, null: false, default: ""
    
    # Si existe user_id, podemos eliminarlo después de migrar los datos
    # remove_column :sales, :user_id, :integer if column_exists?(:sales, :user_id)
  end
end
