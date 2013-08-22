class CreateStopTimes < ActiveRecord::Migration
  def change
    create_table :stop_times do |t|
      t.references :stop
      t.references :trip

      t.timestamps
    end
  end
end
