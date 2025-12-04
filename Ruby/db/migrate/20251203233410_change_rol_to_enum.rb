class ChangeRolToEnum < ActiveRecord::Migration[8.1]
def up
    # 1. agregar nueva columna role (integer)
    add_column :users, :role, :integer, default: 2, null: false
    # Default = empleado (2), cambiamos después si querés

    # 2. migrar los datos desde 'rol' (string)
    User.reset_column_information

    User.find_each do |u|
      case u.rol
      when "administrador"
        u.update_column(:role, 0)
      when "gerente"
        u.update_column(:role, 1)
      else
        u.update_column(:role, 2) # empleado
      end
    end

    # 3. borrar columna antigua
    remove_column :users, :rol
  end

  def down
    # rollback (opcional)
    add_column :users, :rol, :string

    User.reset_column_information

    User.find_each do |u|
      case u.role
      when 0
        u.update_column(:rol, "administrador")
      when 1
        u.update_column(:rol, "gerente")
      else
        u.update_column(:rol, "empleado")
      end
    end

    remove_column :users, :role
  end
end