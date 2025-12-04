class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  load_and_authorize_resource

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    Rails.logger.debug("[UsersController#create] params: #{params[:user].inspect}")
    authorize! :create, @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        Rails.logger.debug("[UsersController#create] errors: #{@user.errors.full_messages.inspect}")
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  # Allow :role only when creating and only if current_user is administrador.
  def user_params
    base = [:nombre, :apellido, :email]
    # Agregar campos de contraseña solo al crear
    if action_name == "create"
      base += [:password, :password_confirmation]
      # Permitir role solo si es administrador
      if current_user&.administrador?
        params.require(:user).permit(*base, :role)
      else
        params.require(:user).permit(*base)
      end
    else
      params.require(:user).permit(*base)
    end
  end
end
