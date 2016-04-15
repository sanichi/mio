class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string   :name, limit: Bucket::MAX_NAME
      t.text     :notes
      t.integer  :mark, default: 0, limit: 1
      t.integer  :sandra, default: 0, limit: 1

      t.timestamps null: false
    end
  end
end
