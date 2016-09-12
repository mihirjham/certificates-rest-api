FactoryGirl.define do
  factory :certificate do
    association :customer, factory: :customer
  end
end
