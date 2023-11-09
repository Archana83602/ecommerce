# frozen_string_literal: true

class OrdersController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  def show
    @order = Spree::Order.find_by!(number: params[:id])
    authorize! :show, @order, cookies.signed[:guest_token]
  end


  def cancel_order
    @order = Spree::Order.find_by!(number: params[:id])

    if @order.can_cancel?
      @order.cancel!
      @order.update(state: 'canceled') # Update the order state to 'canceled'
      flash[:notice] = t('spree.order_cancelled_successfully')
      redirect_to account_path
    else
      flash[:error] = t('spree.order_cancellation_failed')
    end
  end

  private

  def accurate_title
    t('spree.order_number', number: @order.number)
  end

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end
end
