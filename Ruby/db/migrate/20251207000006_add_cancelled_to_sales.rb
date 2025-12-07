class AddCancelledToSales < ActiveRecord::Migration[8.1]
  def change
    # Solo agregamos las columnas si no existen aún, para evitar errores
    # cuando la estructura ya fue modificada previamente.
    unless column_exists?(:sales, :cancelled)
      add_column :sales, :cancelled, :boolean, default: false, null: false
    end

    unless column_exists?(:sales, :cancelled_at)
      add_column :sales, :cancelled_at, :datetime
    end
  end
end
