class AddEmployeeFieldsToSales < ActiveRecord::Migration[8.1]
  def change
    # Agregamos los campos del empleado solo si aún no existen para evitar
    # errores de "duplicate column name" en bases ya migradas.
    unless column_exists?(:sales, :employee_email)
      add_column :sales, :employee_email, :string, null: false, default: ""
    end

    unless column_exists?(:sales, :employee_name)
      add_column :sales, :employee_name, :string, null: false, default: ""
    end
  end
end
