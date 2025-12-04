class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { administrador: 0, gerente: 1, empleado: 2 }

  # No permitir cambiar role una vez creado
  before_update :prevent_role_change, if: :will_save_change_to_role?

  private

  def prevent_role_change
    errors.add(:role, "no puede ser modificado una vez asignado")
    throw(:abort)
  end
end