require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end

  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end

    xit "can filter invoice items by merchant" do      
      expect(@invoice1.invoice_items_for(@merchant1)).to eq([@invoice_item1])
    end
  
    xit "can filter total_revenue by merchant" do
      expect(@invoice1.revenue_for(@merchant1)).to eq(68175)
    end

    it "all_discounts" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 15, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.all_discounts).to eq(0)
      BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.all_discounts).to eq(0)
      BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.all_discounts).to eq(45)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
      
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.all_discounts).to eq(65)
    end

    it "revenue_with_discounts" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 15, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.revenue_with_discounts).to eq(250)
      BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.revenue_with_discounts).to eq(250)

      BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.revenue_with_discounts).to eq(205)
      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
      
      expect(@invoice_1.total_revenue).to eq(250)
      expect(@invoice_1.revenue_with_discounts).to eq(185)
    end

    xit "discounts count by same item, and aren't cumulative to all items" do
      merchantA = Merchant.create!(name: "Queen Soopers")
      discountA = merchantA.bulk_discounts.create!(percentage: 20, quantity: 10, merchant: merchantA)
      itemA = merchantA.items.create!(name: 'Cheese', description: 'Cheddar goodness', unit_price: 1000, merchant: merchantA)
      itemB = merchantA.items.create!(name: 'CousCous', description: 'yummy', unit_price: 2000, merchant: merchantA)
      customer = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')

      invoiceA = Invoice.create!(customer: customer, status: 2)
      invoice_item1 = InvoiceItem.create!(invoice: invoiceA, item: itemA, quantity: 5, unit_price: 1000, status: 1)
      invoice_item2 = InvoiceItem.create!(invoice: invoiceA, item: itemB, quantity: 5, unit_price: 1000, status: 1)

      expect(invoice_item1.discount).to eq(nil) 
      expect(invoice_item2.discount).to eq(nil) 

      invoice_item1.update(quantity: 10)

      expect(invoice_item1.discount).to eq(discountA)
      expect(invoice_item2.discount).to eq(nil)
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

      expect(invoice_item1.discount).to eq(discountA)
      expect(invoice_item2.discount).to eq(discountB)

      discountB.update(percentage: 15)

      expect(invoice_item1.discount).to eq(discountA)
      expect(invoice_item2.discount).to eq(discountA)
    end

    xit "discounts by specific merchant" do
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

      expect(invoice_item1.discount).to eq(discountA)
      expect(invoice_item2.discount).to eq(discountB)
      expect(invoice_item3.discount).to eq(nil)
    end
  end
end
