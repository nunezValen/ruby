class Product < ApplicationRecord
  # ---------------------------
  # Relaciones
  # ---------------------------
  has_many :product_genres, dependent: :destroy
  has_many :genres, through: :product_genres

  # Temporalmente solo una imagen
  has_one_attached :image
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
  validate :image_presence
  validate :image_format_and_size
  validate :at_least_one_genre
  validate :retired_cannot_be_reverted, on: :update

  # ---------------------------
  # Callbacks
  # ---------------------------
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

  def image_presence
    unless image.attached?
      errors.add(:image, "es obligatoria")
    end
  end

  def image_format_and_size
    if image.attached?
      # Verificar formato
      acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
      unless acceptable_types.include?(image.content_type)
        errors.add(:image, "debe ser JPG, PNG, GIF o WebP")
      end

      # Verificar tamaño (máximo 10 MB)
      if image.blob.byte_size > 10.megabytes
        errors.add(:image, "debe pesar menos de 10 MB")
      end
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
end
