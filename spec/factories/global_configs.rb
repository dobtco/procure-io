# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :global_config do
    bid_review_enabled false
    bid_submission_enabled false
    comments_enabled false
    questions_enabled false
    event_hooks "MyText"
  end
end
