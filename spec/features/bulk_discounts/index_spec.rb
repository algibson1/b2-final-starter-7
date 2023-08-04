require "rails_helper"

RSpec.describe "Bulk discounts index page" do
  before :each do
    @merchant1 = Merchant.create!(name: "Hair Care")

    # @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    # @customer_2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    # @customer_3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    # @customer_4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    # @customer_5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    # @customer_6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    # @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    # @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    # @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    # @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    # @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    # @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    # @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    # @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    # @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    # @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    # @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    # @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    # @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    # @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    # @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    # @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    # @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    # @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    # @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    # @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    # @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    # @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    # @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    # @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    # @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @discount1 = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
    @discount2 = BulkDiscount.create!(percentage: 15, quantity: 7, merchant: @merchant1)
    @discount3 = BulkDiscount.create!(percentage: 25, quantity: 15, merchant: @merchant1)
    @discount4 = BulkDiscount.create!(percentage: 30, quantity: 20, merchant: @merchant1)
  end

  #User story 1
  it "links from the dashboard" do
    visit merchant_dashboard_index_path(@merchant1)

    click_link("Bulk Discounts")

    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
  end

  # User stories 1 and 3
  it "lists all merchant's bulk discounts" do
    visit merchant_bulk_discounts_path(@merchant1)

    within("#discount-#{@discount1.id}") do
      expect(page).to have_link("Promotion ##{@discount1.id}", href: merchant_bulk_discount_path(@merchant1, @discount1))
      expect(page).to have_content("20% off bulk purchases of 10 or more items")
      expect(page).to have_link("Delete Promotion ##{@discount1.id}")
    end
    
    within("#discount-#{@discount2.id}") do
      expect(page).to have_link("Promotion ##{@discount2.id}", href: merchant_bulk_discount_path(@merchant1, @discount2))
      expect(page).to have_content("15% off bulk purchases of 7 or more items")
      expect(page).to have_link("Delete Promotion ##{@discount2.id}")
    end
    
    within("#discount-#{@discount3.id}") do
      expect(page).to have_link("Promotion ##{@discount3.id}", href: merchant_bulk_discount_path(@merchant1, @discount3))
      expect(page).to have_content("25% off bulk purchases of 15 or more items")
      expect(page).to have_link("Delete Promotion ##{@discount3.id}")
    end
    
    within("#discount-#{@discount4.id}") do
      expect(page).to have_link("Promotion ##{@discount4.id}", href: merchant_bulk_discount_path(@merchant1, @discount4))
      expect(page).to have_content("30% off bulk purchases of 20 or more items")
      expect(page).to have_link("Delete Promotion ##{@discount4.id}")
    end
  end

  #User story 3
  it "can delete discounts" do
    visit merchant_bulk_discounts_path(@merchant1)
    expect(page).to have_content("Promotion ##{@discount1.id}")

    click_link("Delete Promotion ##{@discount1.id}")

    expect(page).to_not have_content("Promotion ##{@discount1.id}")

  end
end