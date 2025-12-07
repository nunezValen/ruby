# 💎 Proyecto Rails – DiscoStore

Desarrollado por Valentín Nuñez, Uziel Juárez Piñeiro y Zoe Eguaras

---

## Tecnologías Principales

### Backend

* Ruby on Rails 8.1
* SQLite3
* Ruby 3.4.7
* Devise → Autenticación de usuarios
* Cancancan → Autorización y roles
* Kaminari → Paginación
* WickedPDF + wkhtmltopdf → Exportación a PDF
* Groupdate → Agrupaciones por fechas
* Chartkick → Gráficos

### Frontend

* Propshaft → Asset pipeline moderno
* Importmap → Gestión de JS sin Node
* Turbo + Stimulus → Interactividad tipo SPA
* Bootstrap 5

---

## Decisiones de Diseño

### Autenticación y gestión de usuarios

* Se utilizó la gema **Devise** para implementar el inicio y cierre de sesión.
* Se decidió **eliminar la funcionalidad de recuperación de contraseña por email**, ya que no era requerida por el TFI y agregaba complejidad innecesaria al alcance pedido.
* El modelo inicial de *User* fue provisto por Devise y luego adaptado a las necesidades del proyecto.
* Se decidió que los **usuarios tengan borrado físico**, ya que no se especificaba la necesidad de borrado lógico en este caso.
* Como las ventas deben conservar información del empleado aunque este sea eliminado, las ventas almacenan **el nombre y el email del empleado** al momento de la creación.
---

### Permisos

* Para la gestión de permisos según rol (administrador / gerente / empleado), se utilizó la gema **CanCanCan**.
---

### Productos

* Los **productos** tienen **borrado lógico**, siguiendo la indicación explícita del enunciado.
* Para el resto de entidades (usuarios, géneros), el borrado es **físico**.
* Los **géneros** no pueden eliminarse si están asociados al menos a un producto.
* Las **ventas** no se eliminan: solo pueden **cancelarse** y quedan registradas como tal.

#### Estado de los productos (nuevo / usado)

* Se decidió que **una vez creado un producto no se pueda cambiar su estado (nuevo/usado)**.
  El motivo es que cada estado implica reglas distintas (stock fijo en 1, necesidad de audio, manejo del stock, etc.), y permitir el cambio generaba inconsistencias y pérdida de datos.

#### Unicidad de productos

* La unicidad se controla combinando:
  **nombre + autor + estado**.

  * Los productos nuevos deben ser únicos (un solo registro que concentra el stock).
  * Los productos usados pueden repetirse porque representan ejemplares individuales.

#### Stock

* Los productos **nuevos** muestran un **atajo rápido** para incrementar el stock sin entrar en la edición.
* Los productos **usados** siempre tienen stock igual a 1 y este solo cambia por una venta o por cancelarla.
* Los productos dados de baja **no pueden restaurarse**.

#### Imágenes y portada

* La **portada** se carga por separado al crear o editar un producto.
* La galería permite **hasta 5 imágenes adicionales**.
* Al modificar la galería durante la edición, la galería anterior se reemplaza completamente.
* Si la galería no se modifica, las imágenes se borran.
* La portada nunca se borra automáticamente.
---

### Storefront (parte pública)

* La navegación por **género**, **tipo** y **estado** se realiza desde los chips del propio producto.
  Al hacer clic en ellos, se abre la **misma vista de filtros**, pero ya aplicada para ese valor (ej: “ver todos los de Rock”).
* En la parte pública se muestran todos los productos, incluso si su **stock es 0** (solo se excluyen los dados de baja).
* Para mostrar **productos relacionados**, se buscan aquellos que compartan **al menos un género** o **el mismo autor**. Se usa `distinct` y `limit(4)` para evitar duplicados y acotar resultados.
---

### Paginación

* Para la paginación tanto del backstore como del storefront se utilizó **Kaminari**.
---

### Reportes y facturas

* Para gráficos y agrupamientos de reportes se utilizaron:

  * **Chartkick**
  * **Groupdate**
* Para exportar tanto facturas como reportes en **PDF**, se integró **WickedPDF** junto a **wkhtmltopdf**.

#### Reportes de ventas

El sistema cuenta con **varios tipos de reportes**, siempre con los mismos filtros generales:

* **Fecha desde / hasta**
* **Empleado**
* **Género de producto**

Los filtros se pueden **combinar en todas las vistas**.

#### Dashboard rápido (resumen general)

Al ingresar a la sección de reportes, se muestra un **resumen numérico** con:

* Total recaudado
* Ventas activas
* Productos vendidos en ventas activas
* Monto perdido por cancelaciones
* Ventas canceladas
* Productos involucrados en ventas canceladas

Este **dashboard** es el **único reporte que puede exportarse a PDF**.
Todos los demás son gráficos interactivos que *no* se exportan.

**Ventas en el tiempo** → Muestra un **gráfico de puntos** que representa la evolución de las ventas a lo largo del tiempo.

**Ventas por producto** → Muestra cuántas veces fue vendido cada producto.

**Ventas por empleado** → Permite ver cuánto vendió cada empleado.

---

## Instalación del Proyecto

### 1. Clonar repo

```bash
git clone <url>
cd <nombre-del-proyecto>
```

### 2. Instalar gems

```bash
bundle install
```

### 3. Configurar la base de datos

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4. Ejecutar el servidor

```bash
bin/rails server
```

La app queda disponible en:

`http://localhost:3000`

---

## Datos de prueba:

**Usuarios:**

- admin@example.com → Administrador
- ana.gerente@example.com → Gerente
- sofia.empleado@example.com → Empleado

Todos los usuarios del seeder usan la contraseña 12345678.

---
