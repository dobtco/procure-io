# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    commentable_type "MyString"
    commentable_id 1
    officer_id 1
    vendor_id 1
    comment_type "MyString"
    body "MyText"
    data "MyText"
  end
end
