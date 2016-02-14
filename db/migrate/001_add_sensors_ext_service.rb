class AddSensorsExtService < ActiveRecord::Migration
  def change
    add_column :sensors, :ext_service, :integer
    add_column :sensors, :ext_service_ident, :string
  end
end
