FactoryBot.define do
  factory :subject do
    name {
      [
        'Chemistry', 'Economics', 'General Science',
        'History', 'Maths', 'Other',
        'Primary', 'Spanish', 'Art',
        'Classics', 'English Language', 'Geography',
        'ICT', 'Media Studies', 'Physical Education',
        'Psychology', 'Statistics', 'Biology',
        'Design Technology', 'English Literature', 'German',
        'Latin', 'Music', 'Physics',
        'Religious Studies', 'Business Studies', 'Drama',
        'French', 'Health and Social care', 'Law',
        'Politics', 'Sociology'
      ].sample
    }
    initialize_with { Subject.find_or_create_by(name: name) }
  end
end
