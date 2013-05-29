FactoryGirl.define do
  factory :team do
    sequence(:name) { |i| "Team ##{i}" }

    factory :owner_team do
      permission_level { Team.permission_levels[:owner] }
    end
  end
end