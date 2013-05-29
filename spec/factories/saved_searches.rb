FactoryGirl.define do
  factory :saved_search do
    sequence(:name) { |i| "Saved search ##{i}" }
  end
end