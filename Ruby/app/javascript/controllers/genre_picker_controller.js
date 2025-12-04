import { Controller } from "@hotwired/stimulus"

// data-controller="genre-picker"
export default class extends Controller {
  static targets = ["select", "dropdown", "list", "template"]

  connect() {
    this.selected = new Set(this._initialValues())
    this.renderSelected()
  }

  add(event) {
    event.preventDefault()
    const value = this.dropdownTarget.value
    
    if (!value || value === "") return
    if (this.selected.has(value)) return

    this.selected.add(value)
    this._syncSelect()
    this.renderSelected()
    
    // Reset dropdown to prompt
    this.dropdownTarget.value = ""
  }

  remove(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    this.selected.delete(value)
    this._syncSelect()
    this.renderSelected()
  }

  renderSelected() {
    this.listTarget.innerHTML = ""
    this.selected.forEach((value) => {
      const option = this.selectTarget.querySelector(`option[value="${value}"]`)
      if (!option) return

      const clone = this.templateTarget.content.cloneNode(true)
      clone.querySelector("[data-genre-name]").textContent = option.textContent
      const removeButton = clone.querySelector("[data-action]")
      removeButton.dataset.value = value

      this.listTarget.appendChild(clone)
    })
  }

  _syncSelect() {
    this.selectTarget.querySelectorAll("option").forEach((option) => {
      option.selected = this.selected.has(option.value)
    })
  }

  _initialValues() {
    return Array.from(this.selectTarget.querySelectorAll("option:checked")).map(
      (option) => option.value
    )
  }
}

