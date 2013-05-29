FactoryGirl.define do
  factory :form_template do
    sequence(:name) { |i| "Form template ##{i}" }
  end
end