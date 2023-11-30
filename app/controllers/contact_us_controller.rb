# app/controllers/contact_us_controller.rb
class ContactUsController < StoreController
  

    def new
      @contact = Contact.new
    end
  
    def create
      @contact = Contact.new(contact_params)
      if @contact.save
        ContactUsMailer.send_contact_message(@contact).deliver_now
        # Add logic to handle the contact form submission
        # For example, send an email, save to the database, etc.
        # Then redirect or render a thank you page.
        flash[:notice] = 'Thank you for your contacting!'
        
        redirect_to root_path
      else
        render :new
      end
    end
  
    private
  
    def contact_params
      params.require(:contact).permit(:name, :email, :message)
    end
end
  