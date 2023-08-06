require "rails_helper"

RSpec.describe BulkDiscount do
  describe "validations" do
    it {should validate_presence_of :quantity}
    it {should validate_presence_of :percentage}
    it { should validate_numericality_of :quantity }
    it {should validate_numericality_of(:percentage).is_less_than_or_equal_to(99) }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :invoice_items }
  end

end