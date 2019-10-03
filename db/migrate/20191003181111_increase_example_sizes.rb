class IncreaseExampleSizes < ActiveRecord::Migration[6.0]
  def up
    change_column :wk_examples, :japanese, :string, limit: Wk::Example::MAX_EXAMPLE
    change_column :wk_examples, :english, :string, limit: Wk::Example::MAX_EXAMPLE
  end
end
