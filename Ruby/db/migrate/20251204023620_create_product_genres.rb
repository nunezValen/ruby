class CreateProductGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :product_genres do |t|
      t.references :product, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_genres, [:product_id, :genre_id], unique: true
  end
end
