class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user  # si no está logueado, no tiene permisos

    if user.administrador?
      can :manage, :all  # puede todo en toda la aplicación

    elsif user.gerente?
      # PRODUCTOS y VENTAS → puede hacer todo
      # TODO: Descomentar cuando se creen los modelos Product y Sale
      # can :manage, Product
      # can :manage, Sale

      # USUARIOS → puede gestionarlos excepto administradores
      can :read, User
      can [:create, :update, :destroy], User, role: ['gerente', 'empleado']
      can :index, User  # Puede ver el listado de usuarios

      # siempre puede editar SU PROPIA cuenta (excepto el rol)
      can [:read, :update], User, id: user.id

    elsif user.empleado?
      # PRODUCTOS y VENTAS → puede hacer todo

      # USUARIOS → no puede gestionar ninguno, ni ver el listado
      # PERO puede editar su propia cuenta (excepto rol)
      can :show,   User, id: user.id
      can :edit,   User, id: user.id
      can :update, User, id: user.id
    end

    # Reportes de ventas (solo personal autorizado)
    if user.administrador? || user.gerente?
      can :read, :reports
    end

    #
    # Restricción general:
    # NADIE puede cambiar su propio rol.
    #
    cannot :update_role, User # acción personalizada si la usás
  end
end
