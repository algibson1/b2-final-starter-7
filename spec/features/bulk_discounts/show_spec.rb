require "rails_helper"

RSpec.describe "Bulk discount show page" do
  before do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @discount1 = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
    @discount2 = BulkDiscount.create!(percentage: 15, quantity: 7, merchant: @merchant1)
    # @discount3 = BulkDiscount.create!(percentage: 25, quantity: 15, merchant: @merchant1)
    # @discount4 = BulkDiscount.create!(percentage: 30, quantity: 20, merchant: @merchant1)
  end

  # User story 4
  it "displays the percent off and quantity threshold" do
    visit merchant_bulk_discount_path(@merchant1, @discount1)

    expect(page).to have_content("Promotion ##{@discount1.id}")
    expect(page).to have_content("20% off bulk purchases of 10 or more items")
    expect(page).to have_link("Edit Promotion ##{@discount1.id}", href: edit_merchant_bulk_discount_path(@merchant1, @discount1))
    expect(page).to_not have_content("Promotion ##{@discount2.id}")
  end
end