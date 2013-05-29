FactoryGirl.define do
  factory :label do
    sequence(:name) { |i| ProcureFaker::Label.name(i) }
  end
end