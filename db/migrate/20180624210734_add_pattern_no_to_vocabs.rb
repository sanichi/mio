class AddPatternNoToVocabs < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabs, :pattern_no, :integer, limit: 1

    Vocab.where.not(pattern: nil).each do |vocab|
      pattern_no = case vocab.pattern
      when "heiban"
        0
      when "atamadaka"
        1
      when "nakadaka"
        2
      when "odaka"
        3
      else
        nil
      end
      vocab.update_column(:pattern_no, pattern_no)
    end
  end
end
