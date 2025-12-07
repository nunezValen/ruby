import { Controller } from "@hotwired/stimulus"

// Permite hacer scroll horizontal arrastrando con el mouse
// Se aplica al contenedor (ej: .table-responsive)
export default class extends Controller {
  connect() {
    this.isDown = false
    this.startX = 0
    this.scrollLeft = 0

    this.boundOnMouseDown = this.onMouseDown.bind(this)
    this.boundOnMouseLeave = this.onMouseLeave.bind(this)
    this.boundOnMouseUp = this.onMouseUp.bind(this)
    this.boundOnMouseMove = this.onMouseMove.bind(this)

    this.element.addEventListener("mousedown", this.boundOnMouseDown)
    this.element.addEventListener("mouseleave", this.boundOnMouseLeave)
    this.element.addEventListener("mouseup", this.boundOnMouseUp)
    this.element.addEventListener("mousemove", this.boundOnMouseMove)
  }

  disconnect() {
    this.element.removeEventListener("mousedown", this.boundOnMouseDown)
    this.element.removeEventListener("mouseleave", this.boundOnMouseLeave)
    this.element.removeEventListener("mouseup", this.boundOnMouseUp)
    this.element.removeEventListener("mousemove", this.boundOnMouseMove)
  }

  onMouseDown(e) {
    // Solo activar con botón izquierdo
    if (e.button !== 0) return
    this.isDown = true
    this.element.classList.add("is-dragging")
    this.startX = e.pageX - this.element.offsetLeft
    this.scrollLeft = this.element.scrollLeft
  }

  onMouseLeave() {
    this.isDown = false
    this.element.classList.remove("is-dragging")
  }

  onMouseUp() {
    this.isDown = false
    this.element.classList.remove("is-dragging")
  }

  onMouseMove(e) {
    if (!this.isDown) return
    e.preventDefault()
    const x = e.pageX - this.element.offsetLeft
    const walk = (x - this.startX) * -1 // invertir para que arrastre en la dirección natural
    this.element.scrollLeft = this.scrollLeft + walk
  }
}


