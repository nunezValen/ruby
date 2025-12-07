class StorefrontController < ApplicationController
  # El storefront es PÚBLICO - no requiere login

  def index
    @products = Product.active

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

    # Filtro por año
    if params[:year].present?
      @products = @products.where("strftime('%Y', received_on) = ?", params[:year].to_s)
    end

    # Filtro por géneros (múltiples) - Lógica AND: debe tener TODOS los géneros seleccionados
    if params[:genre_ids].present?
      genre_ids = Array(params[:genre_ids]).reject(&:blank?).map(&:to_i)
      if genre_ids.any?
        # Usamos group y having para asegurar que el producto tenga TODOS los géneros
        @products = @products
          .joins(:genres)
          .where(genres: { id: genre_ids })
          .group('products.id')
          .having('COUNT(DISTINCT genres.id) = ?', genre_ids.count)
      end
    end

    @products = @products.includes(:genres, cover_image_attachment: :blob).order(created_at: :desc).page(params[:page]).per(12)
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