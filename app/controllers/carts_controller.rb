# frozen_string_literal: true

class CartsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token
  before_action :assign_order, only: :update
  # note: do not lock the #show action because that's where we redirect when we fail to acquire a lock
  around_action :lock_order, only: :update

  # Shows the current incomplete order from the session
  def show
    @order = current_order(build_order_if_necessary: true)
    authorize! :edit, @order, cookies.signed[:guest_token]
    if params[:id] && @order.number != params[:id]
      flash[:error] = t('spree.cannot_edit_orders')
      redirect_to cart_path
    end
  end

  def update
    authorize! :update, @order, cookies.signed[:guest_token]
    if @order.contents.update_cart(order_params)
      @order.next if params.key?(:checkout) && @order.cart?

      respond_to do |format|
        format.html do
          if params.key?(:checkout)
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to cart_path
          end
        end
      end
    else
      render action: :show
    end
  end

  def empty
    if @order = current_order
      authorize! :update, @order, cookies.signed[:guest_token]
      @order.empty!
    end

    redirect_to cart_path
  end


  # def removeitem
  #   @order = current_order
  #   @line_item = @order.line_items.find(params[:id])
  #   @line_item.destroy
  #   head :ok
  # end


  def ensure_sufficient_stock_lines
    @order = current_order
    if @order.insufficient_stock_lines.present?
      out_of_stock_items = @order.insufficient_stock_lines.collect(&:name).to_sentence
      flash[:error] = t('spree.inventory_error_flash_for_insufficient_quantity', names: out_of_stock_items)
    end
  end

  
  private

  def accurate_title
    t('spree.shopping_cart')
  end

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end

  def order_params
    if params[:order]
      params[:order].permit(*permitted_order_attributes)
    else
      {}
    end
  end

  def assign_order
    @order = current_order
    unless @order
      flash[:error] = t('spree.order_not_found')
      redirect_to(root_path) && return
    end
  end

end
