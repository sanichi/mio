class LinkClassifiersAndTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :classifier, index: true
  end
end
