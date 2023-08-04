class BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index]

  def index
    @discounts = @merchant.bulk_discounts
  end

  private
  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end