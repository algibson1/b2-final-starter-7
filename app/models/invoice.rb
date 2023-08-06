class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, :in_progress, :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def revenue_for(merchant)
    invoice_items.joins(:item).where('merchant_id = ?', merchant.id).sum('invoice_items.quantity*invoice_items.unit_price')
  end

  def invoice_items_for(merchant)
    invoice_items.joins(:item).where('merchant_id = ?', merchant.id)
  end

  def revenue_with_discounts
    total_revenue - all_discounts
  end

  def revenue_with_discounts_for(merchant)
    
  end

  def all_discounts
    Invoice.select("quantity, unit_price, percentage")
      .from(invoice_items
        .joins(:bulk_discounts)
        .select("invoice_items.id, invoice_items.quantity, invoice_items.unit_price, MAX(bulk_discounts.percentage) as percentage")
        .where("invoice_items.quantity >= bulk_discounts.quantity")
        .group("invoice_items.id"))
        .sum("quantity*unit_price*percentage/100")
  end
end

# Below is working raw SQL query
# SELECT SUM(foo.quantity*foo.unit_price*foo.percentage/100) 
# FROM (SELECT invoice_items.id, invoice_items.quantity, invoice_items.unit_price, MAX(bulk_discounts.percentage) as percentage 
#       FROM invoice_items INNER JOIN items ON items.id=invoice_items.item_id 
#       INNER JOIN merchants 
#       ON merchants.id=items.merchant_id 
#       INNER JOIN bulk_discounts 
#       ON bulk_discounts.merchant_id=merchants.id 
#       WHERE invoice_items.invoice_id=1 
#       AND (invoice_items.quantity >= bulk_discounts.quantity) 
#       GROUP BY invoice_items.id) as foo;