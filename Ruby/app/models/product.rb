class Product < ApplicationRecord
    # ---------------------------
    # Relaciones
    # ---------------------------
    has_many :product_genres, dependent: :destroy
    has_many :genres, through: :product_genres
  
    has_many_attached :images
    has_one_attached :audio_preview
  
    # ---------------------------
    # Enums
    # ---------------------------
    enum media_type: { vinyl: 0, cd: 1 }, _prefix: true
    enum state: { new_item: 0, used_item: 1 }, _prefix: true
  
    # ---------------------------
    # Validaciones
    # ---------------------------
    validates :name, :author, :unit_price, :media_type, :state, :received_on, presence: true
    validates :unit_price, numericality: { greater_than: 0 }
  
    validates :stock,
              numericality: { greater_than_or_equal_to: 0 },
              unless: :used_item?
  
    validate :used_items_require_audio
    validate :new_items_cannot_have_audio
  
    # ---------------------------
    # Callbacks
    # ---------------------------
    before_validation :normalize_stock_rules
    before_save :touch_last_inventory_change, if: :will_save_change_to_stock?
  
    # ---------------------------
    # Scopes
    # ---------------------------
    scope :active, -> { where(retired_at: nil) }
  
    # ---------------------------
    # Métodos de dominio
    # ---------------------------
    def soft_delete!
      update!(retired_at: Time.current, stock: 0)
    end
  
    def restore!
      update!(retired_at: nil)
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
      if used_item?
        self.stock = 1
      else
        self.audio_preview.purge if audio_preview.attached?
      end
    end
  
    def used_items_require_audio
      if used_item? && !audio_preview.attached?
        errors.add(:audio_preview, "es obligatorio para productos usados")
      end
    end
  
    def new_items_cannot_have_audio
      if new_item? && audio_preview.attached?
        errors.add(:audio_preview, "no puede tener audio si es un producto nuevo")
      end
    end
  
    # Registrar última modificación del stock
    def touch_last_inventory_change
      self.last_updated_at = Time.current
    end
  end
  