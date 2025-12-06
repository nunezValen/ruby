class Product < ApplicationRecord
  # ---------------------------
  # Relaciones
  # ---------------------------
  has_many :product_genres, dependent: :destroy
  has_many :genres, through: :product_genres

  # Imagen de portada (una sola)
  has_one_attached :cover_image
  # Galería de imágenes (múltiples)
  has_many_attached :gallery
  has_one_attached :audio_preview

  # ---------------------------
  # Enums
  # ---------------------------
  enum :media_type, { vinyl: 0, cd: 1 }, prefix: true
  enum :state,      { new_item: 0, used_item: 1 }, prefix: true

  # ---------------------------
  # Validaciones
  # ---------------------------
  validates :name, :author, :description, :unit_price, :media_type, :state, :received_on, presence: true
  validates :unit_price, numericality: { 
    greater_than: 0, 
    less_than_or_equal_to: 999_999.99 
  }

  validates :stock,
            numericality: { 
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 999_999,
              only_integer: true
            },
            unless: :state_used_item?

  validate :used_items_require_audio
  validate :new_items_cannot_have_audio
  validate :received_on_cannot_be_future
  validate :audio_file_size
  validate :cover_image_presence
  validate :cover_image_format_and_size
  validate :gallery_format_and_size
  validate :gallery_maximum_count
  validate :at_least_one_genre
  validate :retired_cannot_be_reverted, on: :update
  validate :unique_new_name_and_author, if: :state_new_item?

  # ---------------------------
  # Callbacks
  # ---------------------------
  before_validation :set_received_on_default, on: :create
  before_validation :normalize_stock_rules
  before_save :touch_last_inventory_change, if: :will_save_change_to_stock?

  # ---------------------------
  # Scopes
  # ---------------------------
  scope :active,  -> { where(retired: false) }
  scope :retired, -> { where(retired: true) }

  # ---------------------------
  # Métodos de dominio
  # ---------------------------
  def name_with_stock
    "#{name} - Stock: #{stock} - $#{unit_price}"
  end

  def soft_delete!
    return if retired?

    # Forzar baja lógica sin pasar por validaciones/callbacks
    current_time = Time.current
    update_columns(
      retired: true,
      retired_at: current_time,
      stock: 0,
      last_updated_at: current_time,
      updated_at: current_time
    )
  end

  def change_stock!(amount)
    if retired? || state_used_item?
      errors.add(:stock, "no puede modificarse para productos usados o dados de baja")
      raise ActiveRecord::RecordInvalid, self
    end

    update!(stock: [stock + amount, 0].max)
  end

  private

  # ---------------------------
  # Reglas para usados/nuevos
  # ---------------------------

  # Usados → stock = 1 y audio obligatorio
  # Nuevos → stock >= 0 y sin audio
  def normalize_stock_rules
    return if retired?

    if state_used_item?
      self.stock = 1
    else
      self.audio_preview.purge if audio_preview.attached?
    end
  end

  def used_items_require_audio
    if state_used_item? && !audio_preview.attached?
      errors.add(:audio_preview, "es obligatorio para productos usados")
    end
  end

  def new_items_cannot_have_audio
    if state_new_item? && audio_preview.attached?
      errors.add(:audio_preview, "no puede tener audio si es un producto nuevo")
    end
  end

  def received_on_cannot_be_future
    if received_on.present? && received_on > Date.today
      errors.add(:received_on, "no puede ser una fecha futura")
    end
  end

  def audio_file_size
    if audio_preview.attached? && audio_preview.blob.byte_size > 5.megabytes
      errors.add(:audio_preview, "debe pesar menos de 5 MB")
    end
  end

  def cover_image_presence
    unless cover_image.attached?
      errors.add(:cover_image, "es obligatoria")
    end
  end

  def cover_image_format_and_size
    if cover_image.attached?
      # Verificar formato
      acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
      unless acceptable_types.include?(cover_image.content_type)
        errors.add(:cover_image, "debe ser JPG, PNG, GIF o WebP")
      end

      # Verificar tamaño (máximo 10 MB)
      if cover_image.blob.byte_size > 10.megabytes
        errors.add(:cover_image, "debe pesar menos de 10 MB")
      end
    end
  end

  def gallery_format_and_size
    if gallery.attached?
      gallery.each do |image|
        # Verificar formato
        acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
        unless acceptable_types.include?(image.content_type)
          errors.add(:gallery, "debe contener solo imágenes JPG, PNG, GIF o WebP")
          break
        end

        # Verificar tamaño (máximo 10 MB por imagen)
        if image.blob.byte_size > 10.megabytes
          errors.add(:gallery, "cada imagen debe pesar menos de 10 MB")
          break
        end
      end
    end
  end

  def gallery_maximum_count
    return unless gallery.attached?
    
    total_images = gallery.count
    if total_images > 5
      errors.add(:gallery, "solo se permiten máximo 5 imágenes en la galería. Has seleccionado #{total_images} imagen(es)")
    end
  end

  def at_least_one_genre
    if genres.empty?
      errors.add(:genres, "debe tener al menos un género asociado")
    end
  end

  # Un producto dado de baja no puede volver a estar activo
  def retired_cannot_be_reverted
    if retired_in_database == true && retired == false
      errors.add(:retired, "no puede volver a estar activo una vez dado de baja")
    end
  end

  # Registrar última modificación del stock
  def touch_last_inventory_change
    self.last_updated_at = Time.current
  end

  # Fecha de ingreso automática en la creación
  def set_received_on_default
    self.received_on ||= Date.today
  end

  # El stock no se puede cambiar en usados ni dados de baja
  def stock_immutable_for_used_and_retired
    if (retired? || state_used_item?) && will_save_change_to_stock?
      errors.add(:stock, "no puede modificarse para productos usados o dados de baja")
    end
  end

  # Unicidad de productos NUEVOS por nombre + autor (case-insensitive)
  def unique_new_name_and_author
    return if name.blank? || author.blank?

    scope = Product.where(state: :new_item)
                   .where("LOWER(name) = ? AND LOWER(author) = ?", name.downcase, author.downcase)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:base, "Ya existe un producto NUEVO con el mismo nombre y autor")
    end
  end
end
