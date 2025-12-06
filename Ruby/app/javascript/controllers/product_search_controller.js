import { Controller } from "@hotwired/stimulus"

// Maneja la búsqueda de productos
export default class extends Controller {
  static targets = ["searchInput", "results", "productId", "selected", "container"]
  
  connect() {
    this.searchTimeout = null
    this.selectedProduct = null
    
    // Si hay un producto ya seleccionado, mostrarlo
    const productId = this.productIdTarget.value
    if (productId) {
      const searchInput = this.searchInputTarget
      const selectedDiv = this.selectedTarget
      
      // Si el input ya tiene un valor (producto seleccionado), no hacer nada
      if (searchInput.value) {
        selectedDiv.style.display = "block"
      }
    }
  }

  search(event) {
    clearTimeout(this.searchTimeout)
    const query = event.target.value.trim()
    
    if (query.length < 2) {
      this.hideResults()
      return
    }

    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/backstore/sales/search_products?q=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (!response.ok) return
      
      const products = await response.json()
      this.displayResults(products)
    } catch (error) {
      console.error("Error searching products:", error)
    }
  }

  displayResults(products) {
    const resultsContainer = this.resultsTarget
    resultsContainer.innerHTML = ""
    
    if (products.length === 0) {
      resultsContainer.innerHTML = '<div class="dropdown-item-text text-muted">No se encontraron productos</div>'
      this.showResults()
      return
    }

    products.forEach(product => {
      const item = document.createElement("button")
      item.type = "button"
      item.className = "dropdown-item"
      item.innerHTML = `
        <div>
          <strong>${product.name}</strong>
          <div class="small text-muted">${product.author} - Stock: ${product.stock} - $${product.unit_price.toFixed(2)}</div>
        </div>
      `
      item.dataset.productId = product.id
      item.dataset.productPrice = product.unit_price
      item.dataset.productStock = product.stock
      item.dataset.productName = product.name
      item.addEventListener("click", (e) => this.selectProduct(e, product))
      resultsContainer.appendChild(item)
    })
    
    this.showResults()
  }

  selectProduct(event, product) {
    event.preventDefault()
    this.selectedProduct = product
    
    // Establecer el ID del producto en el campo hidden
    this.productIdTarget.value = product.id
    
    // Obtener el item padre para actualizar el precio
    const item = this.productIdTarget.closest("[data-sale-form-target='item']")
    if (item) {
      const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
      if (priceInput) {
        priceInput.value = product.unit_price.toFixed(2)
      }
    }
    
    // Ocultar la barra de búsqueda y mostrar el producto seleccionado
    const searchContainer = this.containerTarget.querySelector(".search-container")
    if (searchContainer) {
      searchContainer.style.display = "none"
    }
    
    // Mostrar el producto seleccionado
    // Buscar el div selected-product que está después del container en el mismo nivel
    const containerParent = this.containerTarget.parentElement
    const selectedDiv = containerParent.querySelector(".selected-product") || this.selectedTarget
    
    if (selectedDiv) {
      selectedDiv.innerHTML = `
        <div class="d-flex align-items-center gap-2">
          <span class="genre-pill">${product.name} - Stock: ${product.stock} - $${product.unit_price.toFixed(2)}</span>
          <button type="button" 
                  class="btn btn-sm btn-outline-secondary" 
                  data-action="click->product-search#changeProduct">
            Cambiar
          </button>
        </div>
      `
      selectedDiv.style.display = "block"
      
      // Reconectar el evento del botón después de cambiar el innerHTML
      const changeButton = selectedDiv.querySelector("button[data-action*='changeProduct']")
      if (changeButton) {
        // Remover listeners anteriores si existen
        const newButton = changeButton.cloneNode(true)
        changeButton.parentNode.replaceChild(newButton, changeButton)
        // Agregar el listener
        newButton.addEventListener("click", (e) => {
          e.preventDefault()
          e.stopPropagation()
          this.changeProduct(e)
        })
      }
    }
    
    // Limpiar el input de búsqueda
    this.searchInputTarget.value = ""
    this.hideResults()
    
    // Disparar evento change en el campo hidden para que sale-form actualice el subtotal
    const changeEvent = new Event("change", { bubbles: true })
    this.productIdTarget.dispatchEvent(changeEvent)
    
    // También disparar updateSubtotal si hay un controlador sale-form
    if (item) {
      const quantityInput = item.querySelector("[data-sale-form-target='quantityInput']")
      if (quantityInput) {
        const subtotalEvent = new Event("change", { bubbles: true })
        quantityInput.dispatchEvent(subtotalEvent)
      }
    }
  }

  changeProduct(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // Mostrar la barra de búsqueda y ocultar el producto seleccionado
    const searchContainer = this.containerTarget.querySelector(".search-container")
    if (searchContainer) {
      searchContainer.style.display = "block"
    }
    
    // Ocultar el badge - buscar por target o por clase
    const containerParent = this.containerTarget.parentElement
    const selectedDiv = containerParent.querySelector(".selected-product") || this.selectedTarget
    if (selectedDiv) {
      selectedDiv.style.display = "none"
    }
    
    // Limpiar el producto seleccionado
    this.productIdTarget.value = ""
    this.selectedProduct = null
    
    // Limpiar el precio
    const item = this.productIdTarget.closest("[data-sale-form-target='item']")
    if (item) {
      const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
      if (priceInput) {
        priceInput.value = ""
      }
      
      // Limpiar el subtotal
      const subtotalDisplay = item.querySelector("[data-sale-form-target='subtotalDisplay']")
      if (subtotalDisplay) {
        subtotalDisplay.value = "0.00"
      }
    }
    
    // Limpiar el input de búsqueda
    this.searchInputTarget.value = ""
    
    // Ocultar resultados si están visibles
    this.hideResults()
    
    // Enfocar el input de búsqueda
    this.searchInputTarget.focus()
    
    // Actualizar el total si hay un controlador sale-form
    if (item) {
      const saleFormController = this.application?.getControllerForElementAndIdentifier(
        item.closest("[data-controller*='sale-form']"),
        "sale-form"
      )
      if (saleFormController && saleFormController.updateTotal) {
        saleFormController.updateTotal()
      }
    }
  }

  showResults() {
    this.resultsTarget.style.display = "block"
  }

  hideResults() {
    this.resultsTarget.style.display = "none"
  }
}
