puts "Eliminando datos existentes..."

SaleItem.delete_all
Sale.delete_all
ProductGenre.delete_all
Product.delete_all
Genre.delete_all
User.delete_all

# =========================================
# Usuarios (25 en total, mezclando roles)
# =========================================
puts "Creando usuarios..."

password_base = "12345678"

usuarios_data = [
  { nombre: "Admin",   apellido: "Principal", email: "admin@example.com",          role: :administrador },
  { nombre: "Ana",     apellido: "Gerente",   email: "ana.gerente@example.com",    role: :gerente },
  { nombre: "Luis",    apellido: "Gerente",   email: "luis.gerente@example.com",   role: :gerente },
  { nombre: "Marta",   apellido: "Gerente",   email: "marta.gerente@example.com",  role: :gerente },
  { nombre: "Julián",  apellido: "Gerente",   email: "julian.gerente@example.com", role: :gerente },
  { nombre: "Sofía",   apellido: "Empleado",  email: "sofia.empleado@example.com", role: :empleado },
  { nombre: "Diego",   apellido: "Empleado",  email: "diego.empleado@example.com", role: :empleado },
  { nombre: "Carla",   apellido: "Empleado",  email: "carla.empleado@example.com", role: :empleado },
  { nombre: "Nico",    apellido: "Empleado",  email: "nico.empleado@example.com",  role: :empleado },
  { nombre: "Paula",   apellido: "Empleado",  email: "paula.empleado@example.com", role: :empleado },
  # Mantengo los que ya tenías
  { nombre: "Gero",    apellido: "Manager",   email: "gerente@example.com",        role: :gerente },
  { nombre: "Emp",     apellido: "Worker",    email: "empleado@example.com",       role: :empleado }
]

# Rellenar hasta 25 usuarios con empleados genéricos
while usuarios_data.size < 25
  idx = usuarios_data.size - 11
  usuarios_data << {
    nombre:   "Empleado#{idx + 1}",
    apellido: "Local",
    email:    "empleado#{idx + 1}@example.com",
    role:     :empleado
  }
end

usuarios_data.each do |attrs|
  User.create!(
    nombre:   attrs[:nombre],
    apellido: attrs[:apellido],
    email:    attrs[:email],
    password: password_base,
    role:     attrs[:role]
  )
end

puts "Usuarios creados: #{User.count}"

# =========================================
# Géneros
# =========================================
puts "Creando géneros..."

genre_names = [
  "Rock",
  "Pop",
  "Punk",
  "Metal",
  "Blues",
  "Jazz",
  "Folk",
  "Soul",
  "Funk",
  "Reggae",
  "Hip Hop",
  "Indie",
  "Progresivo",
  "Psicodelia",
  "Alternativo"
]

genres_by_name = {}
genre_names.each do |name|
  genres_by_name[name] = Genre.create!(name: name)
end

puts "Géneros creados: #{Genre.count}"

# =========================================
# Portadas y audios
# =========================================
puts "Preparando portadas y audios..."

image_dir = Rails.root.join("app/assets/images/seeds")
audio_dir = Rails.root.join("app/assets/audio/seeds")

audio_by_key = {}
Dir[audio_dir.join("*.mp3")].sort.each do |path|
  key = File.basename(path, ".mp3")
  audio_by_key[key] = Pathname.new(path)
end

# =========================================
# Definición de álbumes (25)
#  - 22 nuevos
#  - 3 usados (con audio)
# =========================================
albums = [
  { key: "Beatles-Abbey-Road",                   artist: "The Beatles",            title: "Abbey Road",                                genres: ["Rock"],                        state: :new_item },
  { key: "Black-Sabbath-Black-Sabbath",         artist: "Black Sabbath",          title: "Black Sabbath",                             genres: ["Metal", "Rock"],               state: :new_item },
  { key: "1971-Whos-Next",                      artist: "The Who",                title: "Who's Next",                                genres: ["Rock"],                        state: :new_item },
  { key: "Bob-Dylan-Freewheelin-Bob-Dylan",     artist: "Bob Dylan",              title: "The Freewheelin' Bob Dylan",               genres: ["Folk", "Rock"],                state: :new_item },
  { key: "Carole-King-Tapestry",                artist: "Carole King",            title: "Tapestry",                                  genres: ["Pop", "Folk"],                 state: :new_item },
  { key: "Joy-Division-Unknown-Pleasures",      artist: "Joy Division",           title: "Unknown Pleasures",                         genres: ["Rock", "Alternativo"],         state: :new_item },
  { key: "Pink-Floyd-Dark-Side-of-the-Moon",    artist: "Pink Floyd",             title: "The Dark Side Of The Moon",                genres: ["Rock", "Progresivo"],          state: :used_item },   # USADO
  { key: "Notorious-BIG-ready-to-die",          artist: "The Notorious B.I.G.",   title: "Ready To Die",                              genres: ["Hip Hop"],                     state: :new_item },
  { key: "Patti-Smith-Horses",                  artist: "Patti Smith",            title: "Horses",                                    genres: ["Rock", "Punk"],                state: :new_item },
  { key: "Nirvana-Nevermind",                   artist: "Nirvana",                title: "Nevermind",                                 genres: ["Rock", "Alternativo"],         state: :new_item },
  { key: "Kendrick-Lamar-To-Pimp-a-Butterfly",  artist: "Kendrick Lamar",         title: "To Pimp A Butterfly",                       genres: ["Hip Hop"],                     state: :new_item },
  { key: "Hole-Live-Through-This",              artist: "Hole",                   title: "Live Through This",                         genres: ["Rock", "Alternativo"],         state: :new_item },
  { key: "Beatles-Sgt.-Pepper",                 artist: "The Beatles",            title: "Sgt. Pepper's Lonely Hearts Club Band",     genres: ["Rock", "Psicodelia"],          state: :used_item },   # USADO
  { key: "Talking-Heads-Remain-In-Light",       artist: "Talking Heads",          title: "Remain In Light",                           genres: ["Rock", "Funk", "Alternativo"], state: :new_item },
  { key: "The Wailers, ‘Catch a Fire’",         artist: "The Wailers",            title: "Catch A Fire",                              genres: ["Reggae"],                      state: :new_item },
  { key: "KISS, ‘Alive!’",                      artist: "KISS",                   title: "Alive!",                                    genres: ["Rock"],                        state: :new_item },
  { key: "Led Zeppelin, ‘IV’",                  artist: "Led Zeppelin",           title: "Led Zeppelin IV",                           genres: ["Rock"],                        state: :new_item },
  { key: "Yes-Relayer",                         artist: "Yes",                    title: "Relayer",                                   genres: ["Rock", "Progresivo"],          state: :new_item },
  { key: "Prince-Dirty-Mind",                   artist: "Prince",                 title: "Dirty Mind",                                genres: ["Pop", "Funk"],                 state: :new_item },
  { key: "Outkast-Stankonia",                   artist: "Outkast",                title: "Stankonia",                                 genres: ["Hip Hop", "Funk"],             state: :new_item },
  { key: "Rolling-Stones-Sticky-Fingers",       artist: "The Rolling Stones",     title: "Sticky Fingers",                            genres: ["Rock", "Blues"],               state: :used_item },   # USADO
  { key: "The Rolling Stones, ‘Some Girls’",    artist: "The Rolling Stones",     title: "Some Girls",                                genres: ["Rock"],                        state: :new_item },
  { key: "Sex-Pistols-Never-Mind-The-Bollocks", artist: "Sex Pistols",            title: "Never Mind The Bollocks",                   genres: ["Punk"],                        state: :new_item },
  { key: "Ramones-Ramones",                     artist: "Ramones",                title: "Ramones",                                   genres: ["Punk"],                        state: :new_item },
  { key: "1971-Whos-Next",                      artist: "The Who",                title: "Who's Next (Alt. Edición)",                 genres: ["Rock"],                        state: :new_item }
]

puts "Creando productos (25)..."

albums.each do |album|
  image_path = image_dir.join("#{album[:key]}.webp")

  unless File.exist?(image_path)
    puts "⚠️  No se encontró la imagen #{image_path}, se saltea este producto."
    next
  end

  state = album[:state]
  stock = state == :new_item ? rand(0..40) : 1

  product = Product.new(
    name:        album[:title],
    author:      album[:artist],
    description: "Edición de seed para #{album[:artist]} - #{album[:title]}.",
    unit_price:  rand(15.0..90.0).round(2),
    media_type:  [:vinyl, :cd].sample,
    state:       state,
    stock:       stock,
    received_on: Date.today - rand(0..365).days
  )

  # Asociar géneros
  chosen_genres = album[:genres].map { |g_name| genres_by_name[g_name] }.compact
  chosen_genres = [genres_by_name.values.sample] if chosen_genres.empty?
  product.genres = chosen_genres.uniq

  # Portada
  product.cover_image.attach(
    io: File.open(image_path),
    filename: File.basename(image_path),
    content_type: "image/webp"
  )

  # Audio solo para usados (3 discos)
  if state == :used_item
    audio_path = audio_by_key[album[:key]]

    unless audio_path && File.exist?(audio_path)
      puts "⚠️  No se encontró audio para #{album[:key]} (producto usado), se saltea."
      next
    end

    product.audio_preview.attach(
      io: File.open(audio_path),
      filename: File.basename(audio_path),
      content_type: "audio/mpeg"
    )
  end

  begin
    product.save!
  rescue ActiveRecord::RecordInvalid => e
    puts "⚠️  No se pudo crear '#{album[:artist]} - #{album[:title]}': #{e.record.errors.full_messages.to_sentence}"
  end
end

puts "Productos creados: #{Product.count}"

# =========================================
# Ventas de ejemplo
# =========================================
puts "Creando ventas de ejemplo..."

employees = User.where(role: User.roles.keys).to_a
products_for_sales = Product.active.where("stock > 0").to_a

if employees.empty? || products_for_sales.empty?
  puts "⚠️  No se crearán ventas porque faltan empleados o productos con stock."
else
  60.times do
    employee = employees.sample
    created_at = rand(1..180).days.ago.change(hour: rand(9..20), min: rand(0..59))

    # 30% canceladas
    is_cancelled = rand < 0.3
    cancelled_at = is_cancelled ? [created_at + rand(1..5).hours, Time.current].min : nil

    sale = Sale.new(
      client_name:    "Cliente #{defined?(Faker) ? (Faker::Name.first_name rescue 'Demo') : 'Demo'}",
      client_email:   "cliente#{rand(1000)}@example.com",
      employee_name:  "#{employee.nombre} #{employee.apellido}".strip,
      employee_email: employee.email,
      cancelled:      is_cancelled,
      cancelled_at:   cancelled_at,
      created_at:     created_at,
      updated_at:     created_at
    )
    # Evitar validación de "al menos un producto" al crear, ya que los items
    # se agregan después en este mismo bloque.
    sale.save!(validate: false)

    used_product_ids = []
    rand(1..3).times do
      product = (products_for_sales - products_for_sales.select { |p| used_product_ids.include?(p.id) }).sample
      break unless product

      next if product.stock.to_i <= 0

      quantity =
        if product.state_used_item?
          1
        else
          max_qty = [product.stock.to_i, 5].min
          max_qty = 1 if max_qty < 1
          rand(1..max_qty)
        end

      sale.sale_items.create!(
        product:    product,
        quantity:   quantity,
        unit_price: product.unit_price
      )

      used_product_ids << product.id
    end

    if sale.sale_items.empty?
      sale.destroy
    end
  end

  puts "Ventas creadas: #{Sale.count}"
  puts "Ítems de venta creados: #{SaleItem.count}"
end

puts "Seeds cargadas con éxito ✅"