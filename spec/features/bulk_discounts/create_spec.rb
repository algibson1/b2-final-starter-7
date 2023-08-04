require "rails_helper"

RSpec.describe "bulk discounts create page" do
  before do
    @merchant1 = Merchant.create!(name: "Hair Care")
  end
  
  #User story 2
  it "has a form to create a new discount" do
    visit new_merchant_bulk_discount_path(@merchant1)

    expect(page).to have_content("Create a New Bulk Discount Promotion")
    expect(page).to have_content("Percent off:")
    expect(page).to have_field(:percentage)
    expect(page).to have_content("Quantity threshold:")
    expect(page).to have_field(:quantity)
    expect(page).to have_button("Submit")
  end

  it "can create a new discount" do
    visit merchant_bulk_discounts_path(@merchant1)

    expect(page).to_not have_content("20% off bulk purchases of 10 or more items")
    
    click_link("New Promotion")
    
    fill_in(:percentage, with: 20)
    fill_in(:quantity, with: 10)
    click_button("Submit")
    
    expect(page).to have_content("20% off bulk purchases of 10 or more items")
  end

  it "throws an error if fields left blank" do
    visit new_merchant_bulk_discount_path(@merchant1)

    click_button("Submit")

    expect(page).to have_content("Please fill in all fields")
  end

  it "throws an error if percentage is over 99" do
    visit new_merchant_bulk_discount_path(@merchant1)

    fill_in(:quantity, with: 10)
    fill_in(:percentage, with: 100)
    click_button("Submit")

    expect(page).to have_content("Percent off must be less than 100")
  end
end