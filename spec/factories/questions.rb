FactoryGirl.define do
  factory :question do
    body { ProcureFaker::Question.body }
    answer_body { if rand(0..1) == 0 then Faker::Lorem.paragraph end }
  end
end