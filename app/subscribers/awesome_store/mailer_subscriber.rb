
# frozen_string_literal: true

module AwesomeStore
    class MailerSubscriber
      include Omnes::Subscriber
  
      handle :order_finalized,
             with: :send_admin_confirmation_email,
             id: :admin_order_mailer_send_confirmation_email
  
      # Sends order confirmation email to the admin
      #
      # @param event [Omnes::UnstructuredEvent]
      def send_admin_confirmation_email(event)
        order = event[:order]
        AmazingStore::AdminMailer.confirm_email(order).deliver_later
      end
    end
  end