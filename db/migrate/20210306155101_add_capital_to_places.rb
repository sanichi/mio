class AddCapitalToPlaces < ActiveRecord::Migration[6.1]
  def up
    add_column :places, :capital, :boolean, default: false;

    Place.where(category: "city").each do |c|
      unless c.jname == "下関市" || c.jname == "北九州市"
        c.update_column(:capital, true)
      end
    end
  end

  def down
    remove_column :places, :capital, :boolean
  end
end
