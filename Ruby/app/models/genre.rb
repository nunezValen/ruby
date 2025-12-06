class Genre < ApplicationRecord
  has_many :product_genres, dependent: :restrict_with_error
  has_many :products, through: :product_genres

  before_validation :normalize_name

  validates :name, presence: true
  validate :name_must_be_unique_normalized

  private

  # Normaliza el nombre a CamelCase antes de validar/guardar.
  # Ej: "rock and roll" => "Rock And Roll"
  def normalize_name
    return if name.blank?

    normalized = name.to_s.strip.downcase.split(/\s+/).map(&:capitalize).join(" ")
    self.name = normalized
  end

  # Garantiza unicidad case-insensitive ignorando espacios.
  # Comparar por lower(name) sin espacios.
  def name_must_be_unique_normalized
    return if name.blank?

    normalized_key = name.downcase.gsub(/\s+/, "")

    conflict = Genre
      .where.not(id: id)
      .where("REPLACE(LOWER(name), ' ', '') = ?", normalized_key)

    if conflict.exists?
      errors.add(:name, "ya está en uso")
    end
  end
end

