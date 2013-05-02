class GlobalConfigSerializer < ActiveModel::Serializer
  attributes :bid_review_enabled, :bid_submission_enabled, :comments_enabled, :questions_enabled, :reviewer_leaderboard_enabled
end
