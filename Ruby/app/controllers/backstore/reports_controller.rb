class Backstore::ReportsController < Backstore::BaseController
  before_action :authorize_reports!
  before_action :load_filters
  before_action :load_sales_scope
  before_action :load_employee_emails

  def index
    @total_revenue         = @sales_with_items.sum("sale_items.quantity * sale_items.unit_price")
    @total_sales           = @sales.distinct.count
    @total_items           = @sales_with_items.sum("sale_items.quantity")
    @total_cancelled       = @cancelled_sales.distinct.count
    @total_cancelled_items = @cancelled_sales.joins(:sale_items).sum("sale_items.quantity")
    @lost_revenue          = @cancelled_sales.joins(:sale_items).sum("sale_items.quantity * sale_items.unit_price")
  end

  def sales_over_time
    @sales_over_time = @sales_with_items
      .group_by_day("sales.created_at", range: @date_range)
      .sum("sale_items.quantity * sale_items.unit_price")
  end

  def sales_by_product
    @sales_by_product = @sales_with_items
      .joins(sale_items: :product)
      .group("products.name")
      .sum("sale_items.quantity")
  end

  def sales_by_employee
    @sales_by_employee = @sales_with_items
      .group("sales.employee_name")
      .sum("sale_items.quantity * sale_items.unit_price")
  end

  def export_pdf
    @total_revenue         = @sales_with_items.sum("sale_items.quantity * sale_items.unit_price")
    @total_sales           = @sales.distinct.count
    @total_items           = @sales_with_items.sum("sale_items.quantity")
    @total_cancelled       = @cancelled_sales.distinct.count
    @total_cancelled_items = @cancelled_sales.joins(:sale_items).sum("sale_items.quantity")
    @lost_revenue          = @cancelled_sales.joins(:sale_items).sum("sale_items.quantity * sale_items.unit_price")

    render pdf: "reporte_ventas",
           template: "backstore/reports/index",
           formats: [:pdf],
           layout: "pdf",
           page_size: "A4",
           margin: { top: 10, bottom: 10, left: 10, right: 10 }
  end

  private

  def authorize_reports!
    authorize! :read, :reports
  end

  def load_filters
    @start_date = params[:start_date].presence
    @end_date   = params[:end_date].presence
    @employee   = params[:employee_email].presence
    @genre_id   = params[:genre_id].presence

    start_date = @start_date ? Date.parse(@start_date) : nil
    end_date   = @end_date ? Date.parse(@end_date) : nil
    today      = Date.today

    # La fecha de fin no puede ser futura
    end_date = [end_date, today].compact.min if end_date

    if start_date && end_date
      # La fecha de fin debe ser mayor o igual a la de inicio
      end_date = [end_date, start_date].max
      @date_range = start_date..end_date
    elsif start_date
      @date_range = start_date..today
    elsif end_date
      @date_range = Date.new(2000, 1, 1)..end_date
    else
      @date_range = nil
    end

    # Guardar los valores normalizados para que el formulario los muestre tal cual
    @start_date = start_date&.to_s
    @end_date   = end_date&.to_s

    # Nombre de género para mostrar en filtros (HTML/PDF)
    @genre_name = @genre_id.present? ? Genre.find_by(id: @genre_id)&.name : nil
  rescue ArgumentError
    @date_range = nil
  end

  def load_sales_scope
    base_scope = Sale.includes(:sale_items)
    base_scope = base_scope.where(created_at: @date_range) if @date_range
    base_scope = base_scope.where(employee_email: @employee) if @employee

    if @genre_id
      base_scope = base_scope.joins(sale_items: { product: :genres }).where(genres: { id: @genre_id })
    end

    @sales          = base_scope.where(cancelled: false)
    @cancelled_sales = base_scope.where(cancelled: true)
    @sales_with_items = @sales.joins(:sale_items)
  end

  def load_employee_emails
    # Todos los usuarios con rol válido (administrador, gerente, empleado),
    # ordenados alfabéticamente por email.
    @employee_emails = User
      .where(role: User.roles.keys)
      .order(:email)
      .pluck(:email)
  end
end


