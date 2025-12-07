class AddClientFieldsToSales < ActiveRecord::Migration[8.1]
  def change
    # Igual que en otras migraciones, nos aseguramos de no duplicar columnas.
    unless column_exists?(:sales, :client_name)
      add_column :sales, :client_name, :string
    end

    unless column_exists?(:sales, :client_email)
      add_column :sales, :client_email, :string
    end
  end
end
