class Genre < ApplicationRecord
    has_many :product_genres, dependent: :restrict_with_error
    has_many :products, through: :product_genres
  
    validates :name, presence: true, uniqueness: { case_sensitive: false }
  end
