class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string   :question, limit: Question::MAX_QUESTION
      t.string   :answer1, :answer2, :answer3, :answer4, limit: Question::MAX_ANSWER
      t.integer  :solution, limit: 1
      t.text     :note
      t.integer  :problem_id

      t.index :problem_id
      t.timestamps null: false
    end
  end
end
