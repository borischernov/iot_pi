class AddSensorTransform < ActiveRecord::Migration
  def change
    add_column :sensors, :offset, :float, :default => 0
    add_column :sensors, :factor, :fload, :default => 1
  end
end
