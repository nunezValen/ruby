import { Controller } from "@hotwired/stimulus"

// data-controller="image-gallery"
// data-image-gallery-target="main"
// data-image-gallery-target="thumbnail"
//
// Cada miniatura debe tener data-image-gallery-url con la URL de la imagen grande.

export default class extends Controller {
  static targets = ["main", "thumbnail"]

  connect() {
    // Guardar src inicial para poder volver si hace falta en el futuro
    if (this.hasMainTarget) {
      this.originalSrc = this.mainTarget.src
    }

    // Marcar primera miniatura como activa si existe
    if (this.hasThumbnailTarget) {
      this.clearActive()
      this.thumbnailTargets[0].classList.add("image-thumb-active")
    }
  }

  showFromThumb(event) {
    const thumb = event.currentTarget
    const url = thumb.dataset.imageGalleryUrl
    if (!url || !this.hasMainTarget) return

    this.mainTarget.src = url
    this.clearActive()
    thumb.classList.add("image-thumb-active")
  }

  clearActive() {
    this.thumbnailTargets.forEach((el) => {
      el.classList.remove("image-thumb-active")
    })
  }
}


