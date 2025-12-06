class AddUniqueIndexToGenresOnLowerName < ActiveRecord::Migration[7.1]
  def change
    add_index :genres,
              "lower(name)",
              unique: true,
              name: "index_genres_on_lower_name"
  end
end


