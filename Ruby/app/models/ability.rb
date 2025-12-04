class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user  # si no está logueado, no tiene permisos

    if user.administrador?
      can :manage, :all  # puede todo en toda la aplicación

    elsif user.gerente?
      # PRODUCTOS y VENTAS → puede hacer todo
      can :manage, Product
      can :manage, Sale

      # USUARIOS → puede gestionarlos excepto administradores
      can :read, User
      can [:create, :update, :destroy], User, role: ['gerente', 'empleado']

      # siempre puede editar SU PROPIA cuenta (excepto el rol)
      can [:read, :update], User, id: user.id

    elsif user.empleado?
      # PRODUCTOS y VENTAS → puede hacer todo
      can :manage, Product
      can :manage, Sale

      # USUARIOS → no puede gestionar ninguno
      cannot :manage, User

      # PERO puede editar su propia cuenta (excepto rol)
      can [:read, :update], User, id: user.id
    end

    #
    # Restricción general:
    # NADIE puede cambiar su propio rol.
    #
    cannot :update_role, User # acción personalizada si la usás
  end
end
