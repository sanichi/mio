class AddImageToQuestions < ActiveRecord::Migration[6.1]
  def up
    add_column :questions, :image, :string, limit: Question::MAX_IMAGE

    Question.all.each do |q|
      if [114, 120, 123, 3, 70, 74, 78, 81, 93, 96, 116, 121, 124, 57, 71, 75, 79, 82, 94, 97, 117, 122, 125, 58, 73, 76, 80, 85, 95, 98].include? q.id
        q.update_column(:image, "#{q.id}.#{q.id == 3 ? 'png' : 'jpg'}")
      end
    end
  end

  def down
    remove_column :questions, :image, :string
  end
end
