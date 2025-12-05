class Backstore::ProductsController < Backstore::BaseController
  before_action :set_product, only: %i[ show edit update destroy soft_delete update_stock ]

  # GET /products or /products.json
  def index
    @filter = params[:filter] == "retired" ? "retired" : "active"
    scope = @filter == "retired" ? Product.retired : Product.active
    @products = scope.order(:name)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to backstore_products_path, notice: "Producto creado correctamente." }
        format.json { render :show, status: :created, location: [:backstore, @product] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to [:backstore, @product], notice: "Producto actualizado correctamente.", status: :see_other }
        format.json { render :show, status: :ok, location: [:backstore, @product] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to backstore_products_path, notice: "Producto eliminado correctamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def soft_delete
    @product.soft_delete!
    redirect_to backstore_products_path, notice: "Producto dado de baja"
  end

  def update_stock
    @product.change_stock!(params[:amount].to_i)

    respond_to do |format|
      format.html { redirect_to backstore_products_path, notice: "Stock actualizado" }
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(
        :name, :description, :author, :unit_price, :stock,
        :media_type, :state, :received_on,
        :image, :audio_preview,
        genre_ids: []
      )
    end
end
