require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
    it { should have_one :merchant }
    it { should have_many :bulk_discounts }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)

    end

    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end

    describe "discount method" do
      it "discounts count by same item, and aren't cumulative to all items" do
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

      it "discounts by greatest applicable discount" do
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

      it "discounts by specific merchant" do
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
end