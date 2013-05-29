FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| ProcureFaker::Tag.name(n) }
  end
end