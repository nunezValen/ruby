import { Controller } from "@hotwired/stimulus"

// Maneja la lógica de estado nuevo/usado
export default class extends Controller {
  static targets = ["stateSelect", "stockField", "audioField"]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const isUsed = this.stateSelectTarget.value === "used_item"
    
    if (isUsed) {
      // Producto usado: stock = 1 (deshabilitado), mostrar audio
      this.stockFieldTarget.value = 1
      this.stockFieldTarget.disabled = true
      this.stockFieldTarget.classList.add("bg-light")
      this.audioFieldTarget.classList.remove("d-none")
    } else {
      // Producto nuevo: stock editable, ocultar audio
      this.stockFieldTarget.disabled = false
      this.stockFieldTarget.classList.remove("bg-light")
      this.audioFieldTarget.classList.add("d-none")
    }
  }
}

