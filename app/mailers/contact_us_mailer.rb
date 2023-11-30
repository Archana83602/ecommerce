class ContactUsMailer < ApplicationMailer
    default to: 'your-email@example.com' # Replace with the actual recipient email address
  
    def send_contact_message(contact)
      @contact = contact
      mail(to: @contact.email, subject: 'Thankyou for contacting')

    end
end
  