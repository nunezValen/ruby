class Sale < ApplicationRecord
  # ---------------------------
  # Relaciones
  # ---------------------------
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
  accepts_nested_attributes_for :sale_items, allow_destroy: true, reject_if: :all_blank

  # ---------------------------
  # Validaciones
  # ---------------------------
  validates :employee_email, :employee_name, presence: true
  validates :employee_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :at_least_one_sale_item

  # ---------------------------
  # Métodos de dominio
  # ---------------------------
  def total_amount
    sale_items.sum { |item| item.quantity * item.unit_price }
  end

  def total_items
    sale_items.sum(:quantity)
  end

  private

  def at_least_one_sale_item
    if sale_items.empty? || sale_items.all? { |item| item.marked_for_destruction? || item.product_id.blank? }
      errors.add(:base, "Debe seleccionar al menos un producto")
    end
  end
end
