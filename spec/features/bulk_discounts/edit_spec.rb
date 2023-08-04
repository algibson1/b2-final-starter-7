require "rails_helper"

RSpec.describe "bulk discounts edit page" do
  before do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @discount1 = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
  end

  # User story 5
  it "has a form to edit a discount, prepopulated with info" do
    visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

    expect(page).to have_content("Edit Promotion ##{@discount1.id}")
    expect(page).to have_content("Percent off:")
    expect(page).to have_field(:percentage, with: 20)
    expect(page).to have_content("Quantity threshold:")
    expect(page).to have_field(:quantity, with: 10)
    expect(page).to have_button("Submit")
  end

  it "can update an existing discount" do
    visit merchant_bulk_discounts_path(@merchant1)

    within("#discount-#{@discount1.id}") do
      expect(page).to have_content("20% off bulk purchases of 10 or more items")
      click_link("Edit Promotion ##{@discount1.id}")
    end
    
    fill_in(:percentage, with: 30)
    fill_in(:quantity, with: 20)
    click_button("Submit")
    
    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))

    within("#discount-#{@discount1.id}") do
      expect(page).to have_content("30% off bulk purchases of 20 or more items")
      expect(page).to_not have_content("20% off bulk purchases of 10 or more items")
    end
  end

  it "throws an error if fields left blank" do
    visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

    fill_in(:percentage, with: "")
    click_button("Submit")
    expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @discount1))

    expect(page).to have_content("Please fill in all fields")
  end

  it "throws an error if percentage is over 99" do
    visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

    fill_in(:quantity, with: 10)
    fill_in(:percentage, with: 100)
    click_button("Submit")

    expect(page).to have_content("Percent off must be less than 100")
  end
end