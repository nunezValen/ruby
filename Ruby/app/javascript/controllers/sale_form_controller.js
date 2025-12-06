import { Controller } from "@hotwired/stimulus"

// Maneja la lógica del formulario de ventas
export default class extends Controller {
  static targets = [
    "items", 
    "item", 
    "itemTemplate", 
    "productSelect", 
    "productIdHidden",
    "quantityInput", 
    "unitPriceInput", 
    "subtotalDisplay", 
    "totalDisplay",
    "destroyInput"
  ]

  connect() {
    this.updateTotal()
    // Inicializar el índice basado en los items existentes
    const existingItems = this.itemTargets.length
    this.itemIndex = existingItems > 0 ? existingItems : 0
    
    // Inicializar eventos para items existentes
    this.itemTargets.forEach(item => {
      this.updateItemEvents(item)
    })
  }

  addItem(event) {
    event.preventDefault()
    
    const template = this.itemTemplateTarget.content.cloneNode(true)
    const newItem = template.querySelector("[data-sale-form-target='item']")
    
    // Reemplazar INDEX con el índice actual
    const index = this.itemIndex++
    const html = newItem.innerHTML.replace(/INDEX/g, index)
    newItem.innerHTML = html
    
    // Agregar el nuevo item
    this.itemsTarget.appendChild(newItem)
    
    // Forzar la inicialización de Stimulus en el nuevo elemento
    // Esto asegura que los controladores se inicialicen correctamente
    const application = this.application || window.Stimulus
    if (application) {
      application.load(newItem)
    }
    
    // Actualizar eventos
    this.updateItemEvents(newItem)
  }

  removeItem(event) {
    event.preventDefault()
    const item = event.currentTarget.closest("[data-sale-form-target='item']")
    const destroyInput = item.querySelector("[data-sale-form-target='destroyInput']")
    
    if (destroyInput) {
      destroyInput.value = "1"
    }
    
    item.remove()
    this.updateTotal()
  }

  updatePrice(event) {
    const select = event.currentTarget
    const item = select.closest("[data-sale-form-target='item']")
    const option = select.options[select.selectedIndex]
    
    if (option && option.dataset.price) {
      const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
      if (priceInput) {
        const price = parseFloat(option.dataset.price)
        priceInput.value = price.toFixed(2)
        this.updateSubtotalForItem(item)
      }
    } else {
      const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
      if (priceInput) {
        priceInput.value = ""
      }
      this.updateSubtotalForItem(item)
    }
  }

  async updatePriceFromHidden(event) {
    const hiddenInput = event.currentTarget
    const item = hiddenInput.closest("[data-sale-form-target='item']")
    const productId = hiddenInput.value
    
    if (!productId) {
      const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
      if (priceInput) {
        priceInput.value = ""
      }
      this.updateSubtotalForItem(item)
      return
    }
    
    // Obtener el precio del producto desde el servidor
    try {
      const response = await fetch(`/backstore/sales/search_products?q=${encodeURIComponent(productId)}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (response.ok) {
        const products = await response.json()
        const product = products.find(p => p.id.toString() === productId.toString())
        
        if (product) {
          const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
          if (priceInput) {
            priceInput.value = product.unit_price.toFixed(2)
            this.updateSubtotalForItem(item)
          }
        } else {
          // Si no se encuentra, intentar buscar directamente por ID
          const directResponse = await fetch(`/backstore/sales/search_products?q=${productId}`, {
            headers: {
              "Accept": "application/json",
              "X-Requested-With": "XMLHttpRequest"
            }
          })
          if (directResponse.ok) {
            const directProducts = await directResponse.json()
            const directProduct = directProducts.find(p => p.id.toString() === productId.toString())
            if (directProduct) {
              const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
              if (priceInput) {
                priceInput.value = directProduct.unit_price.toFixed(2)
                this.updateSubtotalForItem(item)
              }
            }
          }
        }
      }
    } catch (error) {
      console.error("Error fetching product price:", error)
    }
  }

  updateSubtotal(event) {
    const item = event.currentTarget.closest("[data-sale-form-target='item']")
    this.updateSubtotalForItem(item)
  }

  updateSubtotalForItem(item) {
    const quantityInput = item.querySelector("[data-sale-form-target='quantityInput']")
    const priceInput = item.querySelector("[data-sale-form-target='unitPriceInput']")
    const subtotalDisplay = item.querySelector("[data-sale-form-target='subtotalDisplay']")
    
    if (quantityInput && priceInput && subtotalDisplay) {
      const quantity = parseFloat(quantityInput.value) || 0
      const price = parseFloat(priceInput.value) || 0
      const subtotal = (quantity * price).toFixed(2)
      subtotalDisplay.value = subtotal
    }
    
    this.updateTotal()
  }

  updateTotal() {
    let total = 0
    
    this.subtotalDisplayTargets.forEach(display => {
      const value = parseFloat(display.value) || 0
      total += value
    })
    
    if (this.totalDisplayTarget) {
      this.totalDisplayTarget.textContent = `$ ${total.toFixed(2)}`
    }
  }

  updateItemEvents(item) {
    // Los eventos ya están configurados con data-action en el HTML
    // Establecer precio inicial si hay un producto seleccionado (para items existentes con producto)
    const productIdHidden = item.querySelector("[data-sale-form-target='productIdHidden']")
    if (productIdHidden && productIdHidden.value) {
      // Si hay un producto seleccionado, obtener su precio
      this.updatePriceFromHidden({ currentTarget: productIdHidden })
    }
    
    // Actualizar subtotal si hay valores
    this.updateSubtotalForItem(item)
  }
}

