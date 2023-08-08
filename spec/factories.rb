FactoryBot.define do
  factory :customer do
    first_name {Faker::Name.first_name}
    last_name {Faker::Dessert.variety}
  end

  factory :invoice do
    status {[0,1,2].sample}
    customer
  end

  factory :merchant do
    name {Faker::Space.galaxy}
  end

  factory :item do
    name {Faker::Coffee.variety}
    description {Faker::Hipster.sentence}
    unit_price {Faker::Number.decimal(l_digits: 2)}
    merchant
  end

  factory :transaction do
    result {[0,1].sample}
    credit_card_number {Faker::Finance.credit_card}
    invoice
  end

  factory :invoice_item do
    status {[0,1,2].sample}
    item
    invoice
  end

  factory :bulk_discount do
    percentage {[10,20,25,30].sample}
    quantity {[10,15,20,25,30,35,40].sample}
    merchant
  end
end
