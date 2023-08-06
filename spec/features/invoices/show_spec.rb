require "rails_helper"

RSpec.describe "invoices show" do
  before :each do
    @merchant1 = Merchant.create!(name: "Hair Care")
    @merchant2 = Merchant.create!(name: "Jewelry")

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)
    @item_7 = Item.create!(name: "Scrunchie", description: "This holds up your hair but is bigger", unit_price: 3, merchant_id: @merchant1.id)
    @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)

    @item_5 = Item.create!(name: "Bracelet", description: "Wrist bling", unit_price: 200, merchant_id: @merchant2.id)
    @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant_id: @merchant2.id)

    @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    @customer_2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    @customer_3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    @customer_4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    @customer_5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    @customer_6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-28 14:54:09")
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 2)

    @invoice_8 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 2)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_2.id, quantity: 2, unit_price: 8, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_3.id, quantity: 3, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 1, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_7.id, quantity: 1, unit_price: 3, status: 1)
    @ii_8 = InvoiceItem.create!(invoice_id: @invoice_7.id, item_id: @item_8.id, quantity: 1, unit_price: 5, status: 1)
    @ii_9 = InvoiceItem.create!(invoice_id: @invoice_7.id, item_id: @item_4.id, quantity: 1, unit_price: 1, status: 1)
    @ii_10 = InvoiceItem.create!(invoice_id: @invoice_8.id, item_id: @item_5.id, quantity: 1, unit_price: 1, status: 1)
    @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 12, unit_price: 6, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_2.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_3.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_4.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_5.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 0, invoice_id: @invoice_6.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_7.id)
    @transaction8 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_8.id)
  end

  it "shows the invoice information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@invoice_1.id)
    expect(page).to have_content(@invoice_1.status)
    expect(page).to have_content(@invoice_1.created_at.strftime("%A, %B %-d, %Y"))
  end

  it "shows the customer information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@customer_1.first_name)
    expect(page).to have_content(@customer_1.last_name)
    expect(page).to_not have_content(@customer_2.last_name)
  end

  it "shows the item information" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_1.unit_price)
    expect(page).to_not have_content(@ii_4.unit_price)

  end

  it "shows a select field to update the invoice status" do
    visit merchant_invoice_path(@merchant1, @invoice_1)
    
    within("#the-status-#{@ii_1.id}") do
      page.select("cancelled")
      click_button "Update Invoice"
      
      expect(page).to have_content("cancelled")
    end
    
    within("#current-invoice-status") do
      expect(page).to_not have_content("in progress")
    end
  end

  xit "only shows items for this merchant" do
    InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 12, unit_price: 6, status: 1)
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content("something") #placeholder
    expect(page).to_not have_content("another thing") #placeholder
  end
  
  # User story 6 
  it "shows the total (non-discounted) revenue for this invoice for this merchant" do
    InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_5.id, quantity: 12, unit_price: 6, status: 1)
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(@invoice_1.total_revenue).to eq(250)
    expect(@invoice_1.revenue_for(@merchant1)).to eq(162.0)
    expect(page).to have_content("Total Revenue: 162.0")
    expect(page).to_not have_content("250")
    #check for unit testing
  end

  xit "shows final discounted revenue for this invoice for this merchant" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content("Total Revenue: 162.0")
    expect(page).to_not have_content("Final Revenue With Discounts:")
    
    discount = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
    
    visit merchant_invoice_path(@merchant1, @invoice_1)

    expect(page).to have_content("Total Revenue: 162")
    expect(page).to have_content("Final Revenue With Discounts: #{@invoice_1.revenue_with_discounts_for(@merchant1)}")
  end
  #   6: Merchant Invoice Show Page: Total Revenue and Discounted Revenue

# As a merchant
# When I visit my merchant invoice show page
# Then I see the total revenue for my merchant from this invoice (not including discounts)
# And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation

  xit "discounts count by same item, and aren't cumulative to all items" do
    merchantA = Merchant.create!(name: "Queen Soopers")
    discountA = merchantA.bulk_discounts.create!(percentage: 20, quantity: 10, merchant: merchantA)
    itemA = merchantA.items.create!(name: 'Cheese', description: 'Cheddar goodness', unit_price: 1000, merchant: merchantA)
    itemB = merchantA.items.create!(name: 'CousCous', description: 'yummy', unit_price: 2000, merchant: merchantA)
    customer = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')

    invoiceA = Invoice.create!(customer: customer, status: 2)
    invoice_item1 = InvoiceItem.create!(invoice: invoiceA, item: itemA, quantity: 5, unit_price: 1000, status: 1)
    invoice_item2 = InvoiceItem.create!(invoice: invoiceA, item: itemB, quantity: 5, unit_price: 1000, status: 1)

    visit merchant_invoice_path(mechantA, invoiceA)
    expect(page).to_not have_content("20% off")
    expect(page).to_not have_content("whatever the discount total is")

    invoice_item1.update(quantity: 10)
    visit merchant_invoice_path(mechantA, invoiceA)
    expect(page).to have_content("whatever the discount total is")

    within("#invoice-#{invoice_item1.id}") do
      expect(page).to have_content("20% Off")
    end

    within("#invoice-#{invoice_item2.id}") do
      expect(page).to_not have_content("20% Off")
    end
  end

  xit "discounts by greatest applicable discount" do
    merchantA = Merchant.create!(name: "Queen Soopers")
    discountA = merchantA.bulk_discounts.create!(percentage: 20, quantity: 10, merchant: merchantA)
    discountB = merchantA.bulk_discounts.create!(percentage: 30, quantity: 15, merchant: merchantA)
    itemA = merchantA.items.create!(name: 'Cheese', description: 'Cheddar goodness', unit_price: 1000, merchant: merchantA)
    itemB = merchantA.items.create!(name: 'CousCous', description: 'yummy', unit_price: 2000, merchant: merchantA)
    customer = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')

    invoiceA = Invoice.create!(customer: customer, status: 2)
    invoice_item1 = InvoiceItem.create!(invoice: invoiceA, item: itemA, quantity: 12, unit_price: 1000, status: 1)
    invoice_item2 = InvoiceItem.create!(invoice: invoiceA, item: itemB, quantity: 15, unit_price: 1000, status: 1)

    visit merchant_invoice_path(merchantA, invoiceA)
    within("#invoice_item_#{invoice_item1.id}") do
      expect(page).to have_content("20% Off")
    end

    within("#invoice_item_#{invoice_item2.id}") do
      expect(page).to have_content("30% Off")
    end

    expect(page).to have_content("whatever revenue_with_discounts_for_merchant is")

    discountB.update(percentage: 15)
    visit merchant_invoice_path(merchantA, invoiceA)
    within("#invoice_item_#{invoice_item1.id}") do
      expect(page).to have_content("20% Off")
    end

    within("#invoice_item_#{invoice_item2.id}") do
      expect(page).to have_content("20% Off")
    end

    expect(page).to have_content("whatever the new revenue_with_discounts_for_merchant is")
  end

  xit "discounts are not affected by other merchant items on invoice" do
    merchantA = Merchant.create!(name: "Queen Soopers")
    merchantB = Merchant.create!(name: "Someone Else")
    discountA = merchantA.bulk_discounts.create!(percentage: 20, quantity: 10, merchant: merchantA)
    discountB = merchantA.bulk_discounts.create!(percentage: 30, quantity: 15, merchant: merchantA)
    itemA = merchantA.items.create!(name: 'Cheese', description: 'Cheddar goodness', unit_price: 1000, merchant: merchantA)
    itemB = merchantA.items.create!(name: 'CousCous', description: 'yummy', unit_price: 2000, merchant: merchantA)
    itemC = merchantB.items.create!(name: 'Thing', description: 'just a thing', unit_price: 3000, merchant: merchantB)
    customer = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')

    invoiceA = Invoice.create!(customer: customer, status: 2)
    invoice_item1 = InvoiceItem.create!(invoice: invoiceA, item: itemA, quantity: 12, unit_price: 1000, status: 1)
    invoice_item2 = InvoiceItem.create!(invoice: invoiceA, item: itemB, quantity: 15, unit_price: 2000, status: 1)
    invoice_item3 = InvoiceItem.create!(invoice: invoiceA, item: itemC, quantity: 15, unit_price: 3000, status: 1)

    visit merchant_invoice_path(merchantA, invoiceA)

    within("#invoice_item_#{invoice_item1.id}") do
      expect(page).to have_content("20% Off")
    end

    within("#invoice_item_#{invoice_item2.id}") do
      expect(page).to have_content("30% Off")
    end

    expect(page).to have_content("total merchant revenue")
    expect(invoice_item1.discount).to eq(discountA)
    expect(invoice_item2.discount).to eq(discountB)
    expect(invoice_item3.discount).to eq(nil)
  end

  # User story 7
  xit "shows discounts for each item, where applicable" do
    visit merchant_invoice_path(@merchant1, @invoice_1)

    within("#the-status-#{@ii_11.id}") do
      expect(page).to_not have_link("20% off")
    end

    discount = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)

    visit merchant_invoice_path(@merchant1, @invoice_1)

    within("#the-status-#{@ii_11.id}") do
      expect(page).to have_link("20% off", href: merchant_bulk_discount_path(@merchant1, discount))
    end
  end
end
