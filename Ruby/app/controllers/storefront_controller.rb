class StorefrontController < ApplicationController
  # El storefront es PÚBLICO - no requiere login
  layout "storefront"

  def index
    @products = Product.active.includes(:genres, cover_image_attachment: :blob)

    # Filtro por título del álbum
    if params[:title].present?
      @products = @products.where("LOWER(name) LIKE ?", "%#{params[:title].downcase}%")
    end

    # Filtro por artista
    if params[:artist].present?
      @products = @products.where("LOWER(author) LIKE ?", "%#{params[:artist].downcase}%")
    end

    # Filtro por tipo (vinilo o CD)
    if params[:media_type].present?
      @products = @products.where(media_type: params[:media_type])
    end

    # Filtro por estado (nuevo o usado)
    if params[:state].present?
      @products = @products.where(state: params[:state])
    end

    # Filtro por género
    if params[:genre_id].present?
      @products = @products.joins(:genres).where(genres: { id: params[:genre_id] })
    end

    # Filtro por año
    if params[:year].present?
      @products = @products.where("strftime('%Y', received_on) = ?", params[:year].to_s)
    end

    @products = @products.distinct.order(created_at: :desc)
    @genres = Genre.order(:name)
  end

  def show
    @product = Product.active.find(params[:id])

    # Discos relacionados: mismo género o mismo autor (máximo 4)
    @related_products = Product.active
                               .where.not(id: @product.id)
                               .left_joins(:genres)
                               .where(genres: { id: @product.genre_ids })
                               .or(
                                 Product.active
                                        .where.not(id: @product.id)
                                        .where(author: @product.author)
                               )
                               .distinct
                               .limit(4)
  end
end