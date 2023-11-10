# app/controllers/addresses_controller.rb

class AddressesController < ApplicationController
    before_action :load_user
    before_action :load_address, only: [:edit, :update]
  
    def edit
    end
  
    def update
      if @address.update(address_params)
        redirect_to user_path(@user), notice: 'Address updated successfully.'
      else
        render :edit
      end
    end
  
    private
  
    def load_user
      @user = User.find(params[:user_id])
    end
  
    def load_address
      @address = @user.bill_address # Change this based on your logic
    end
  
    def address_params
      params.require(:address).permit(:firstname, :lastname, :address1, :address2, :city, :zipcode, :phone, :state_name, :alternative_phone, :company, :state_id, :country_id, :name)
    end
  end
  