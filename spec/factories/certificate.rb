FactoryGirl.define do
  factory :certificate do
    body "Certificate body"
    active true
    private_key "a" * 16
    association :customer, factory: :customer
  end
end
