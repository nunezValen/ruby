import { Controller } from "@hotwired/stimulus"

// Controlador genérico de confirmación por modal reutilizable
// Uso típico:
//   form_with ..., data: { action: "submit->confirm-modal#open", confirm_message: "¿Mensaje?" }
//
// El formulario no se envía hasta que el usuario confirma en el modal.
export default class extends Controller {
  static targets = ["modal", "message", "confirmButton"]

  connect() {
    // Bootstrap modal instance
    this.bootstrapModal = null
    this.formToSubmit = null
  }

  open(event) {
    // Si ya fue confirmado, dejar pasar el submit normal
    if (event.target.dataset.confirmModalDisabled === "true") {
      return
    }

    event.preventDefault()

    this.formToSubmit = event.target

    const message =
      this.formToSubmit.dataset.confirmMessage ||
      "¿Estás seguro de que querés continuar?"

    this.messageTarget.textContent = message

    if (!this.bootstrapModal) {
      // eslint-disable-next-line no-undef
      this.bootstrapModal = new bootstrap.Modal(this.modalTarget)
    }

    this.bootstrapModal.show()
  }

  confirm() {
    if (this.formToSubmit) {
      // Marcar el formulario para no volver a interceptarlo
      this.formToSubmit.dataset.confirmModalDisabled = "true"
      this.bootstrapModal.hide()
      // Enviar el formulario original
      this.formToSubmit.requestSubmit()
      this.formToSubmit = null
    }
  }
}


