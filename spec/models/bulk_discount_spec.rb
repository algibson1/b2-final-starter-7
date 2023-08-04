require "rails_helper"

RSpec.describe BulkDiscount do
  describe "validations" do
    it {should validate_presence_of :quantity}
    it {should validate_presence_of :percentage}
  end

  describe "relationships" do
    it {should belong_to :merchant}
  end

  # it "kicks in when enough items are ordered" do
  #   # need one merchant, one item, one bulk discount, one invoice, n - 1 invoice items
  #   # check that unit_price on invoice_items matches unit_price on items 
  #   # add one more invoice_items
  #   # check that price in invoice_items is now discounted
  # end

  # it "is eligible for all items a merchant sells" do
  #   # need one merchant, two items, one bulk discount, one invoice, n-1 invoice_items per item
  #   # check that each item's unit_price is same as item unit_price
  #   # add one more invoice_item for first item
  #   # check that first item has been discounted, but second has not
  #   # add another invoice_item for second item
  #   # check both are discounted
  # end

end