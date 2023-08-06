require "rails_helper"

describe "Admin Invoices Index Page" do
  before :each do
    @m1 = Merchant.create!(name: "Merchant 1")
    @m2 = Merchant.create!(name: "Merchant 2")

    @c1 = Customer.create!(first_name: "Yo", last_name: "Yoz", address: "123 Heyyo", city: "Whoville", state: "CO", zip: 12345)
    @c2 = Customer.create!(first_name: "Hey", last_name: "Heyz")

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: "2012-03-25 09:54:09")
    @i2 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: "2012-03-25 09:30:09")

    @item_1 = Item.create!(name: "test", description: "lalala", unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: "rest", description: "dont test me", unit_price: 12, merchant_id: @m1.id)
    @item_3 = Item.create!(name: "another", description: "here we go again", unit_price: 15, merchant_id: @m2.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 15, unit_price: 1, status: 1)
    @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_2.id, quantity: 87, unit_price: 12, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_3.id, quantity: 30, unit_price: 20, status: 1)

    visit admin_invoice_path(@i1)
  end

  it "should display the id, status and created_at" do
    expect(page).to have_content("Invoice ##{@i1.id}")
    expect(page).to have_content("Created on: #{@i1.created_at.strftime("%A, %B %d, %Y")}")

    expect(page).to_not have_content("Invoice ##{@i2.id}")
  end

  it "should display the customers name and shipping address" do
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
    expect(page).to have_content(@c1.address)
    expect(page).to have_content("#{@c1.city}, #{@c1.state} #{@c1.zip}")

    expect(page).to_not have_content("#{@c2.first_name} #{@c2.last_name}")
  end

  it "should display all the items on the invoice" do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)
    expect(page).to have_content(@item_3.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)
    expect(page).to have_content(@ii_4.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")
    expect(page).to have_content("$#{@ii_4.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)
    expect(page).to have_content(@ii_4.status)

    expect(page).to_not have_content(@ii_3.quantity)
    expect(page).to_not have_content("$#{@ii_3.unit_price}")
    expect(page).to_not have_content(@ii_3.status)
  end

  it "should have status as a select field that updates the invoices status" do
    within("#status-update-#{@i1.id}") do
      select("cancelled", :from => "invoice[status]")
      expect(page).to have_button("Update Invoice")
      click_button "Update Invoice"

      expect(current_path).to eq(admin_invoice_path(@i1))
      expect(@i1.status).to eq("completed")
    end
  end

  #User story 8
  it "should display the (non-discounted) total revenue the invoice will generate" do
    expect(page).to have_content("Total Revenue: $#{@i1.total_revenue}")

    expect(page).to_not have_content(@i2.total_revenue)
  end

  it "should display total revenue after discounts" do
    expect(@i1.revenue_with_discounts).to eq(@i1.total_revenue)
    expect(page).to_not have_content("Final Revenue With Discounts:")
    
    BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @m1)
    visit admin_invoice_path(@i1)

    expect(@i1.revenue_with_discounts).to eq(@i1.total_revenue)
    expect(page).to_not have_content("Final Revenue With Discounts:")

    BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @m1)
    visit admin_invoice_path(@i1)

    expect(@i1.total_revenue).to eq(639)
    expect(@i1.revenue_with_discounts).to eq(634.5)
    expect(page).to have_content("Final Revenue With Discounts: $634.50")

    BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @m1)
    visit admin_invoice_path(@i1)

    expect(@i1.total_revenue).to eq(639)
    expect(@i1.revenue_with_discounts).to eq(629.7)
    expect(page).to have_content("Final Revenue With Discounts: $629.70")

    BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @m2)
    visit admin_invoice_path(@i1)

    expect(@i1.total_revenue).to eq(639)
    expect(@i1.revenue_with_discounts).to eq(509.7)
    expect(page).to have_content("Final Revenue With Discounts: $509.70")
  end

  it "shows discounts for each item, where applicable" do
    visit admin_invoice_path(@i1)

    expect(page).to_not have_content("20% Off")
    expect(page).to_not have_content("30% Off")
    discount1 = BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @m1)
    discount2 = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @m1)
    discount3 = BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @m2)

    visit admin_invoice_path(@i1)

    expect(@ii_1.discount).to eq(discount2)
    within("#the-status-#{@ii_1.id}-admin") do
      expect(page).to have_content("20% Off")
    end
    
    expect(@ii_2.discount).to eq(discount1)
    within("#the-status-#{@ii_2.id}-admin") do
      expect(page).to have_content("30% Off")
    end

    expect(@ii_4.discount).to eq(discount3)
    within("#the-status-#{@ii_4.id}-admin") do
      expect(page).to have_content("20% Off")
    end
  end
end
