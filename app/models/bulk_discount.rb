class BulkDiscount < ApplicationRecord
  validates_presence_of :percentage, :quantity

  belongs_to :merchant
end