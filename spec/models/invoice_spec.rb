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
    before do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Queen Soopers')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_9 = Item.create!(name: "Cheese", description: "It's cheese", unit_price: 10, merchant: @merchant2, status: 1)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 15, unit_price: 10, status: 1)
      @ii_12 = InvoiceItem.create!(invoice: @invoice_1, item: @item_9, quantity: 12, unit_price: 9, status: 1)
    end

    it "calculates total_revenue for all merchants and items" do
      expect(@invoice_1.total_revenue).to eq(378.0)
    end

    it "can filter invoice items by merchant" do      
      expect(@invoice_1.invoice_items_for(@merchant1)).to eq([@ii_1, @ii_11])
    end
  
    it "can filter total revenue by merchant" do
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_for(@merchant2)).to eq(108)
    end

    it "calculates discounts across all items and merchants, when discount quantity thresholds are met, and uses greatest potential discount" do
      expect(@invoice_1.total_revenue).to eq(378)
      expect(@invoice_1.all_discounts).to eq(0)
      expect(@invoice_1.revenue_with_discounts).to eq(378)

      BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(378)
      expect(@invoice_1.all_discounts).to eq(0)
      expect(@invoice_1.revenue_with_discounts).to eq(378)

      BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @merchant1)
      expect(@invoice_1.total_revenue).to eq(378)
      expect(@invoice_1.all_discounts).to eq(45)
      expect(@invoice_1.revenue_with_discounts).to eq(333)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
      
      expect(@invoice_1.total_revenue).to eq(378)
      expect(@invoice_1.all_discounts).to eq(69)
      expect(@invoice_1.revenue_with_discounts).to eq(309)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant2)

      expect(@invoice_1.total_revenue).to eq(378)
      expect(@invoice_1.all_discounts).to eq(90.6)
      expect(@invoice_1.revenue_with_discounts).to eq(287.4)
    end

    it "calculates total discounts for merchant" do
      expect(@invoice_1.discounts_for(@merchant1)).to eq(0)
      expect(@invoice_1.discounts_for(@merchant2)).to eq(0)
      BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @merchant1)

      expect(@invoice_1.discounts_for(@merchant1)).to eq(0)
      expect(@invoice_1.discounts_for(@merchant2)).to eq(0)

      BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @merchant1)

      expect(@invoice_1.discounts_for(@merchant1)).to eq(45)
      expect(@invoice_1.discounts_for(@merchant2)).to eq(0)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
      
      expect(@invoice_1.discounts_for(@merchant1)).to eq(69)
      expect(@invoice_1.discounts_for(@merchant2)).to eq(0)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant2)

      expect(@invoice_1.discounts_for(@merchant1)).to eq(69)
      expect(@invoice_1.discounts_for(@merchant2)).to eq(21.6)
    end

    it "calculates total revenue with discounts by merchant" do
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_for(@merchant2)).to eq(108)
      expect(@invoice_1.revenue_with_discounts_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_with_discounts_for(@merchant2)).to eq(108)
      BulkDiscount.create!(percentage: 40, quantity: 20, merchant: @merchant1)
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_with_discounts_for(@merchant1)).to eq(270)

      BulkDiscount.create!(percentage: 30, quantity: 15, merchant: @merchant1)
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_with_discounts_for(@merchant1)).to eq(225)
      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant1)
      
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_with_discounts_for(@merchant1)).to eq(201)
      expect(@invoice_1.revenue_for(@merchant2)).to eq(108)
      expect(@invoice_1.revenue_with_discounts_for(@merchant2)).to eq(108)

      BulkDiscount.create!(percentage: 20, quantity: 10, merchant: @merchant2)
      
      expect(@invoice_1.revenue_for(@merchant1)).to eq(270)
      expect(@invoice_1.revenue_with_discounts_for(@merchant1)).to eq(201)
      expect(@invoice_1.revenue_for(@merchant2)).to eq(108)
      expect(@invoice_1.revenue_with_discounts_for(@merchant2)).to eq(86.4)
    end
  end
end
