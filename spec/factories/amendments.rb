FactoryGirl.define do
  factory :amendment do
    sequence(:title) { |i| "Amendment ##{i}" }
  end
end