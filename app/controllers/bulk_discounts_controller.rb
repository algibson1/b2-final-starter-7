class BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :new, :destroy]

  def index
    @discounts = @merchant.bulk_discounts
  end

  def new

  end

  def create
    discount = BulkDiscount.new(discount_params)
    if discount.save
      redirect_to merchant_bulk_discounts_path(discount_params)
    else
      redirect_to new_merchant_bulk_discount_path(discount_params)
      flash[:alert] = "Please fill in all fields" if params[:percentage].empty? || params[:quantity].empty?
      flash[:alert] = "Percent off must be less than 100" if params[:percentage].to_i > 99
    end
  end

  def show
    @discount = BulkDiscount.find_by(discount_params)
  end

  def destroy
    discount = BulkDiscount.find_by(discount_params)
    discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  private
  def discount_params
    params.permit(:percentage, :quantity, :merchant_id, :id)
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end