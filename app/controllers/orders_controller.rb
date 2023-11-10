# frozen_string_literal: true

class OrdersController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  def show
    @order = Spree::Order.find_by!(number: params[:id])
    authorize! :show, @order, cookies.signed[:guest_token]
  end

  # Method to cancel the order
  def cancel_order
    @order = Spree::Order.find_by!(number: params[:id])
    if @order.can_cancel?
      @order.cancel!
      @order.update(state: 'canceled') # Update the order state to 'canceled'
      flash[:notice] = t('spree.order_cancelled_successfully')
    else
      flash[:error] = t('spree.order_cancellation_failed')
    end
  end
  
  def return_order
    @order = Spree::Order.find_by!(number: params[:id])
    print(@order)
    order_attributes = @order.attributes
    # Print more attributes as needed
    puts "Order Attributes: #{order_attributes}"
    if @order.can_cancel? && order_placed_within_last_week?
      
      @order.cancel!
      @order.update(state: 'return', shipment_state:'ready', canceled_at: Time.current)
      flash[:notice] = t('spree.order_returned_successfully')
    else
      flash[:error] = t('spree.order_return_time_limit_exceeded')
    end
    redirect_to order_path(@order)
  end

  private

  def order_placed_within_last_week?
    @order.created_at >= 1.week.ago
  end

  def accurate_title
    t('spree.order_number', number: @order.number)
  end

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end
end
