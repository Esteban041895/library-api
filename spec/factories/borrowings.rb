FactoryBot.define do
  factory :borrowing do
    association :user
    association :book
    borrowed_at { Date.today }
    due_date { 2.weeks.from_now.to_date }
    returned_at { nil }

    trait :overdue do
      borrowed_at { 3.weeks.ago.to_date }
      due_date { 1.week.ago.to_date }
    end

    trait :returned do
      returned_at { Date.today }
    end

    trait :due_today do
      due_date { Date.today }
    end
  end
end
