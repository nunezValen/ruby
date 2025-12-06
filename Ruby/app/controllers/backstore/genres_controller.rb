class Backstore::GenresController < Backstore::BaseController
  before_action :set_genre, only: %i[ destroy ]

  # GET /genres or /genres.json
  def index
    @genres = Genre.all
  end

  # GET /genres/new
  def new
    @genre = Genre.new
  end

  # POST /genres or /genres.json
  def create
    @genre = Genre.new(genre_params)

    respond_to do |format|
      if @genre.save
        format.html { redirect_to backstore_genres_path, notice: "Género creado correctamente." }
        format.json { render :index, status: :created, location: backstore_genres_path }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /genres/1 or /genres/1.json
  def destroy
    respond_to do |format|
      if @genre.destroy
        format.html { redirect_to backstore_genres_path, notice: "Género eliminado correctamente.", status: :see_other }
      else
        # Por ejemplo, cuando tiene productos asociados (dependent: :restrict_with_error)
        format.html { redirect_to backstore_genres_path, alert: "No se puede eliminar este género porque tiene productos asociados.", status: :see_other }
      end
    end
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_genre
      @genre = Genre.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def genre_params
      params.require(:genre).permit(:name)
    end
end
