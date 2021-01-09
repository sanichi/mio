class AddImageToPictures < ActiveRecord::Migration[6.1]
  def up
    add_column :pictures, :image, :string, limit: Picture::MAX_IMAGE

    Picture.all.each do |p|
      fend = "jpg"
      fend = "png" if [360,359,358,353,352,62,61,60,9].include?(p.id)
      p.update_column(:image, "#{p.id}.#{fend}")
    end
  end

  def down
    remove_column :pictures, :image, :string
  end
end
