class BulkDiscountsController < ApplicationController
  before_action :find_merchant, except: [:update, :create]
  before_action :find_discount, only: [:show, :edit, :update, :destroy]

  def index
    @discounts = @merchant.bulk_discounts
    @upcoming_holidays = HolidayService.new.next_3_holidays
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
  end

  def edit
  end
  
  def update
    if @discount.update(discount_params)
      redirect_to merchant_bulk_discounts_path(discount_params)
    else
      redirect_to edit_merchant_bulk_discount_path(discount_params)
      flash[:alert] = "Please fill in all fields" if params[:percentage].empty? || params[:quantity].empty?
      flash[:alert] = "Percent off must be less than 100" if params[:percentage].to_i > 99
    end
  end

  def destroy
    @discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
    flash[:alert] = "Promotion ##{@discount.id} Successfully Deleted"
  end

  private
  def discount_params
    params.permit(:percentage, :quantity, :merchant_id, :id)
  end

  def find_discount
    @discount = BulkDiscount.find(params[:id])
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end