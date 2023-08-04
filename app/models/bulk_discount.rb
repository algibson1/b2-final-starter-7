class BulkDiscount < ApplicationRecord
  validates_presence_of :percentage, :quantity
  validates :percentage, numericality: { less_than_or_equal_to: 99 }
  validates_numericality_of :quantity

  belongs_to :merchant
end