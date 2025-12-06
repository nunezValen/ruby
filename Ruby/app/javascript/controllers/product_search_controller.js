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
    const selectedBadge = this.selectedTarget.querySelector(".badge")
    selectedBadge.textContent = `${product.name} - Stock: ${product.stock} - $${product.unit_price.toFixed(2)}`
    this.selectedTarget.style.display = "block"
    
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
    // Mostrar la barra de búsqueda y ocultar el producto seleccionado
    const searchContainer = this.containerTarget.querySelector(".search-container")
    if (searchContainer) {
      searchContainer.style.display = "block"
    }
    this.selectedTarget.style.display = "none"
    
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
    }
    
    // Limpiar el input de búsqueda
    this.searchInputTarget.value = ""
    
    // Enfocar el input de búsqueda
    this.searchInputTarget.focus()
  }

  showResults() {
    this.resultsTarget.style.display = "block"
  }

  hideResults() {
    this.resultsTarget.style.display = "none"
  }
}
