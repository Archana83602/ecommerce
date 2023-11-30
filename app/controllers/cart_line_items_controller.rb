# frozen_string_literal: true

class CartLineItemsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  # Adds a new item to the order (creating a new order if none already exists)
  def create
    @order = current_order(create_order_if_necessary: true)
    authorize! :update, @order, cookies.signed[:guest_token]

    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1

    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    if !quantity.between?(1, 2_147_483_647)
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    else
      begin
        @line_item = @order.contents.add(variant, quantity)
      rescue ActiveRecord::RecordInvalid => error
        @order.errors.add(:base, error.record.errors.full_messages.join(", "))
      end
    end

    respond_to do |format|
      format.html do
        if @order.errors.any?
          flash[:error] = @order.errors.full_messages.join(", ")
          redirect_back_or_default(root_path)
          return
        else
          redirect_to cart_path
        end
      end
    end
  end

  def destroy
    @order = current_order
    @line_item = @order.line_items.find(params[:id])

    if @line_item.destroy
      # Update order's cost_price by reducing the value of the deleted item
      @order.update(item_total: @order.item_total - @line_item.cost_price)
      @order.update( total: @order.total - @line_item.cost_price * @line_item.quantity, item_count: @order.item_count-@line_item.quantity)

      # If there are no items left in the order, delete the order
      @order.destroy if @order.line_items.empty?

      flash[:success] = t('spree.item_removed_from_cart')
    else
      flash[:error] = t('spree.failed_to_remove_item')
    end

    respond_to do |format|
      format.html { redirect_to cart_path }
    end
  end
  

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end
end
