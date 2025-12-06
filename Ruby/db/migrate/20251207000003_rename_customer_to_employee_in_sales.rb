class RenameCustomerToEmployeeInSales < ActiveRecord::Migration[8.1]
  def change
    rename_column :sales, :customer_email, :employee_email
    rename_column :sales, :customer_name, :employee_name
  end
end
