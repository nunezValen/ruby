class Backstore::BaseController < ApplicationController
    layout "backstore"

    # autenticación del usuario empleado
    before_action :authenticate_user!
  end
  