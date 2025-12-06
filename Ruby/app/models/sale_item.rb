class SaleItem < ApplicationRecord
  # ---------------------------
  # Relaciones
  # ---------------------------
  belongs_to :sale
  belongs_to :product

  # ---------------------------
  # Callbacks
  # ---------------------------
  before_validation :set_unit_price_from_product, if: :product_id_changed?

  # ---------------------------
  # Validaciones
  # ---------------------------
  validates :quantity, presence: true, 
                       numericality: { 
                         greater_than: 0, 
                         only_integer: true 
                       }
  validates :unit_price, presence: true,
                         numericality: { 
                           greater_than: 0 
                         }
  validate :quantity_does_not_exceed_stock

  # ---------------------------
  # Métodos de dominio
  # ---------------------------
  def subtotal
    return 0 if quantity.blank? || unit_price.blank?
    quantity * unit_price
  end

  private

  def set_unit_price_from_product
    if product && unit_price.blank?
      self.unit_price = product.unit_price
    end
  end

  def quantity_does_not_exceed_stock
    return unless product && quantity.present?

    if quantity > product.stock
      errors.add(:quantity, "no puede ser mayor al stock disponible (#{product.stock} unidades)")
    end
  end
end
