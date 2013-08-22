class CreateVehiclePositions < ActiveRecord::Migration
  def change
    create_table :vehicle_positions do |t|
      t.decimal :lat, :precision => 10, :scale => 7
      t.decimal :lon, :precision => 10, :scale => 7
      t.decimal :bearing, :precision => 5, :scale => 2
      t.decimal :odometer, :precision => 8, :scale => 2
      t.decimal :speed, :precision => 4, :scale => 2
      t.timestamp :timestamp
      t.references :trip, index: true
      t.references :vehicle, index: true

      t.timestamps
    end
  end
end
