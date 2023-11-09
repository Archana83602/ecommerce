# frozen_string_literal: true

class UsersController < StoreController
  skip_before_action :set_current_order, only: :show, raise: false
  prepend_before_action :authorize_actions, only: :new

  include Taxonomies

  def show
    load_object
    @orders = @user.orders.complete.order('completed_at desc')
  end

  def create
    @user = Spree::User.new(user_params)
    if @user.save

      if current_order
        session[:guest_token] = nil
      end

      redirect_back_or_default(root_url)
    else
      render :new
    end
  end

  def edit
    load_object
  end

  # def update
  #   load_object
  #   if @user.update(user_params)
  #     spree_current_user.reload
  #     redirect_url = account_url

  #     if params[:user][:password].present?
  #       # this logic needed b/c devise wants to log us out after password changes
  #       if Spree::Auth::Config[:signout_after_password_change]
  #         redirect_url = login_url
  #       else
  #         bypass_sign_in(@user)
  #       end
  #     end
  #     redirect_to redirect_url, notice: I18n.t('spree.account_updated')
  #   else
  #     render :edit
  #   end
  # end

  def update
    load_object

    # Check if there are address parameters in the request
    if params[:user][:bill_address_attributes].present?
      edit_address_name
    end

    if @user.update(user_params)
      spree_current_user.reload
      redirect_url = account_url

      if params[:user][:password].present?
        # this logic needed b/c devise wants to log after password changes
        if Spree::Auth::Config[:signout_after_password_change]
          redirect_url = login_url
        else
          bypass_sign_in(@user)
        end
      end

      redirect_to redirect_url, notice: I18n.t('spree.account_updated')
    else
      render :edit
    end
  end
 

  def edit_address_name
    load_object
  end

  private

  def user_params
    params.require(:user).permit(Spree::PermittedAttributes.user_attributes | [:email])
  end

  def load_object
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @bill_address ||= @user&.bill_address
    authorize! params[:action].to_sym, @user
    
  end

  def authorize_actions
    authorize! params[:action].to_sym, Spree::User.new
  end

  def accurate_title
    I18n.t('spree.my_account')
  end

  def update_address_name
    if @user.bill_address
      new_bill_address = Spree::Address.new(@user.bill_address.attributes)
      address_params = params[:user][:bill_address_attributes].permit(:name, :address1, :address2, :city, :zipcode, :phone)
  
      # Assign other attributes
      new_bill_address.assign_attributes(address_params)
  
      # Assign the new address to the user
      @user.bill_address = new_bill_address
  
      # Set the user's ID if it doesn't already have one
      @user.id ||= spree_current_user&.id
    end
  end
  
  
  
  def orderhistory
    @user ||= Spree::User.find_by(id: spree_current_user&.id)
    @orders = @user.orders.complete.order('completed_at desc')
 
  end


  
  # def updateaddress
  #   @user = Spree::User.find_by(id: spree_current_user&.id)
  #   @addresses = SpreeUserAddress.where(user_id: @user.id).order(created_at: :desc).first
  #   @address = SpreeAddress.find_by(id: @addresses.address_id)
  #   @address.update(address_params)
  #   if @address.nil?
  #     redirect_to orderhistory_path
  #   end
  # end
    
  

 

  # def address_params
  #   params.require(:spree_address).permit(:address1, :address2, :city, :zipcode, :phone, :state_name, :alternative_phone, :company, :state_id, :country_id)
  # end
end