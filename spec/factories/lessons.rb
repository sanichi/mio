FactoryBot.define do
  factory :lesson do
    book       { [Faker::Internet.url.truncate(Lesson::MAX_BOOK), nil ].sample }
    chapter    { Faker::Book.title.truncate(Lesson::MAX_CHAPTER) }
    chapter_no { rand(Lesson::MAX_CHAPTER_NO) + 1 }
    complete   { rand(Lesson::MAX_COMPLETE) + 1 }
    eco        { ["E04", "A94-A96", "A01,B12,C23,D34,E45", nil, nil].sample}
    link       { Faker::Internet.url.truncate(Lesson::MAX_LINK) }
    section    { Faker::Book.title.truncate(Lesson::MAX_SECTION) }
    series     { Faker::Book.title.truncate(Lesson::MAX_SERIES) }
  end
end
