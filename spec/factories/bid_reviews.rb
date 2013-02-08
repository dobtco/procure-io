# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bid_review do
    starred false
    read false
    officer_id 1
    bid_id 1
  end
end
