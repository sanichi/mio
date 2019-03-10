FactoryBot.define do
  factory :lesson do
    chapter    { Faker::Book.title.truncate(Lesson::MAX_CHAPTER) }
    chapter_no { rand(Lesson::MAX_CHAPTER_NO + 1) }
    complete   { rand(Lesson::MAX_COMPLETE + 1) }
    link       { Faker::Internet.url.truncate(Lesson::MAX_LINK) }
    section    { Faker::Book.title.truncate(Lesson::MAX_SECTION) }
    series     { Faker::Book.title.truncate(Lesson::MAX_SERIES) }
  end
end
