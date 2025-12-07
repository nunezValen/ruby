// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import "chartkick"
import "Chart.bundle"

// Configuración global de Chartkick (colores de la marca)
if (window.Chartkick) {
  window.Chartkick.options = {
    colors: ["#c20406"], // rojo de la app
  }
}
