# app/controllers/addresses_controller.rb
class AddressesController < StoreController
  # before_action :authenticate_user! # Ensure the user is logged in

 
  def new
    @address = Spree::Address.new
    @countries = Spree::Country.all
  end
  def create
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @addresses = Spree::UserAddress.new(user_id: @user.id)
  
    # Fetch the last ID and increment it
    last_id = Spree::Address.maximum(:id)
    new_id = last_id ? last_id + 1 : 1
  
    # Create a new Spree::Address record with the incremented ID
    @address = Spree::Address.new(address_params)
    @address.id = new_id
  
    # Create a new Spree::UserAddress record for the user
    @addresses.address_id = new_id
  
    if @address.save && @addresses.save
      redirect_to root_path, notice: 'Address created successfully.'
    end
    # else
    #   flash[:alert] = 'Failed to create address.'
    #   render :new
    # end
  end
  
  def edit
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @address = Spree::Address.find_by(id: params[:id])
  
    # Check if there is a Spree::UserAddress record for the given address and user
    unless Spree::UserAddress.exists?(user_id: @user.id, address_id: @address.id)
      raise ActiveRecord::RecordNotFound, "Couldn't find Spree::Address with 'id'=#{params[:id]} for the current user."
    end
  end
  

  

  def index
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @user_addresses = @user.user_addresses.includes(:address)
  
    # Extracting the addresses from the user_addresses association
    @addresses = @user_addresses.map(&:address)
    
  end
  

  def update
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @address = Spree::Address.find_by(id: params[:id])
  
    if @address.nil? 
      raise ActiveRecord::RecordNotFound, "Couldn't find Spree::Address with 'id'=#{params[:id]} for the current user."
    end
  
    @address.readonly!
    
    # Assign the new attribute values
    @address.attributes = address_params
    puts @address.inspect  
  
    if @address.save
      redirect_to root_path, notice: 'Address updated successfully.'
    else
      flash[:alert] = 'Failed to update address. Record is marked as readonly.'
      render :edit
    end
  end
  

  def set_default
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @address = Spree::Address.find_by(id: params[:id])
    @order ||= Spree::Order.find_by(user_id: spree_current_user&.id)
  
    if @address && @user
      Spree::UserAddress.transaction do
        # Set default and default_billing attributes to false for all addresses of the user
        @user.user_addresses.update_all(default: false, default_billing: false)
  
        # Set the selected address as the default billing
        user_address = @user.user_addresses.find_or_create_by(address_id: @address.id)
        user_address.update(default: true, default_billing: true)
        @user.update(ship_address_id: @address.id, bill_address_id: @address.id)
  
        # Fetch the order with the maximum order ID for the user and update it
        max_order = Spree::Order.where(user_id: spree_current_user&.id).order(id: :desc).first
        max_order.update(ship_address_id: @address.id, bill_address_id: @address.id) if max_order
      end
  
      redirect_to addresses_path, notice: 'Address set as default billing successfully.'
    else
      flash[:alert] = 'Failed to set address as default billing.'
      redirect_to addresses_path
    end
  end
  
  
  def destroy
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @address = Spree::Address.find_by(id: params[:id])

    if @address.nil?
      raise ActiveRecord::RecordNotFound, "Couldn't find Spree::Address with 'id'=#{params[:id]} for the current user."
    end

    if @user 
      # If the deleted address is set as the default billing or shipping address, update user's default addresses
      @user.user_addresses.find_by(address_id: @address.id)&.destroy

      # if @user.bill_address_id == @address.id || @user.ship_address_id == @address.id
      #   @user.update(bill_address_id: nil, ship_address_id: nil)
      # end

      # Update any orders that reference the deleted address
      # Spree::Order.where(ship_address_id: @address.id).update_all(ship_address_id: nil)
      # Spree::Order.where(bill_address_id: @address.id).update_all(bill_address_id: nil)

      redirect_to addresses_path, notice: 'Address deleted successfully.'
    else
      flash[:alert] = 'Failed to delete address.'
      redirect_to addresses_path
    end
  end

  private

  def address_params
    params.require(:address).permit(:name, :address1, :address2, :city, :zipcode, :phone, :state_id, :country_id)
  end
  


end
