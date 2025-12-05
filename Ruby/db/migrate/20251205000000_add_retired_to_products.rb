class AddRetiredToProducts < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :retired, :boolean, default: false, null: false

    execute <<-SQL.squish
      UPDATE products
      SET retired = TRUE
      WHERE retired_at IS NOT NULL
    SQL
  end

  def down
    remove_column :products, :retired
  end
end
