# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all

User.create!(
  nombre: "Admin",
  apellido: "Master",
  email: "admin@example.com",
  password: "12345678",
  role: 0 # Administrador
)

User.create!(
  nombre: "Gero",
  apellido: "Manager",
  email: "gerente@example.com",
  password: "12345678",
  role: 1 # Gerente
)

User.create!(
  nombre: "Emp",
  apellido: "Worker",
  email: "empleado@example.com",
  password: "12345678",
  role: 2 # Empleado
)

puts "Seeds cargadas con éxito!"
